# encoding: UTF-8
require 'spec_helper'

describe 'Defining a Record' do
  context 'when the definition is correct' do
    it 'should not raise any exception' do
      expect {
        class PersonRecord < Fixy::Record
          include Fixy::Formatter::Alphanumeric

          set_record_length 20

          set_line_ending Fixy::Record::LINE_ENDING_CRLF

          field :first_name, 10, '1-10' , :alphanumeric
          field :last_name , 10, '11-20', :alphanumeric
        end
      }.not_to raise_error
    end
  end

  context 'when the definition is incorrect' do
    it 'should raise appropriate exception' do
      expect {
        class PersonRecordA < Fixy::Record
          set_record_length 20
          field :first_name, 10, '1-10', :alphanumeric
        end
      }.to raise_error(ArgumentError, "Unknown type 'alphanumeric'")

      expect {
        class PersonRecordB < Fixy::Record
          include Fixy::Formatter::Alphanumeric
          set_record_length 20
          field :first_name, 2, '1-10', :alphanumeric
        end
      }.to raise_error(ArgumentError, "Invalid Range (size: 2, range: 1-10)")

      expect {
        class PersonRecordC < Fixy::Record
          include Fixy::Formatter::Alphanumeric
          set_record_length 20
          field :first_name, 10, '1-10', :alphanumeric
          field :last_name , 10, '10-19', :alphanumeric
        end
      }.to raise_error(ArgumentError, "Column 1 has already been allocated")

      expect {
        class PersonRecordD < Fixy::Record
          include Fixy::Formatter::Alphanumeric
          set_record_length 10
          field :first_name, 10, '1-10', :alphanumeric
          field :last_name , 10, '11-20', :alphanumeric
        end
      }.to raise_error(ArgumentError, "Invalid Range (> 10)")
    end
  end
end

describe 'Generating a Record' do
  context 'when properly defined' do
    class PersonRecordE < Fixy::Record
      include Fixy::Formatter::Alphanumeric

      set_record_length 20

      field :first_name, 10, '1-10' , :alphanumeric
      field :last_name , 10, '11-20', :alphanumeric

      field_value :first_name, -> { 'Sarah' }

      def last_name
        'Kerrigan'
      end
    end

    it 'should generate fixed width record' do
      PersonRecordE.new.generate.should eq "Sarah     Kerrigan  \n"
    end

    context 'when using the debug flag' do
      it 'should produce a debug log' do
        PersonRecordE.new.generate(true).should eq File.read('spec/fixtures/debug_record.txt')
      end
    end
  end

  context 'when dealing with multi-byte characters' do
    it 'should generate fixed width record' do
      class PersonRecordMultibyte < Fixy::Record
        include Fixy::Formatter::Alphanumeric

        set_record_length 9

        field :name, 9, '1-9' , :alphanumeric

        field_value :name, -> { "12345678И" }
      end

      value = PersonRecordMultibyte.new.generate
      value.should be_valid_encoding
      value.should == "12345678 \n"
    end
  end

  context 'when a field value is nil' do
    it 'should emit spaces' do
      class PersonRecordNil < Fixy::Record
        include Fixy::Formatter::Alphanumeric

        set_record_length 9

        field :name, 9, '1-9' , :alphanumeric

        field_value :name, -> { nil }
      end

      value = PersonRecordNil.new.generate
      value.should == "         \n"
    end
  end

  context 'when definition is incomplete (e.g. undefined columns)' do
    it 'should raise an error' do
      class PersonRecordF < Fixy::Record
        include Fixy::Formatter::Alphanumeric
        set_record_length 20
        field :first_name, 10, '1-10' , :alphanumeric
        field :last_name , 8,  '11-18', :alphanumeric
        field_value :first_name, -> { 'Sarah' }
        field_value :last_name,  -> { 'Kerrigan' }
      end

      expect {
        PersonRecordF.new.generate
      }.to raise_error(StandardError, "Undefined field for position 19")
    end
  end

  context 'when inheriting from another record' do
    class PersonRecordG < Fixy::Record
      include Fixy::Formatter::Alphanumeric
      set_record_length 20

      field :first_name, 10, '1-10' , :alphanumeric
      field_value :first_name, -> { 'Bob' }
    end

    class PersonRecordH < PersonRecordG
      include Fixy::Formatter::Alphanumeric
      set_record_length 20
      field :last_name , 10,  '11-20', :alphanumeric
      field_value :last_name,  -> { 'Williams' }
    end

    it 'should include fields from the superclass' do
      PersonRecordH.new.generate.slice(0, 10).should eq 'Bob       '
      PersonRecordH.new.generate.slice(10, 10).should eq 'Williams  '
    end

    context 'when two records inherit' do
      class PersonRecordI < PersonRecordG
        include Fixy::Formatter::Alphanumeric
        set_record_length 20
        field :last_name , 10,  '11-20', :alphanumeric
        field_value :last_name,  -> { 'Jacobs' }
      end

      it 'does not collide' do
        PersonRecordH.new.generate.slice(0, 10).should eq 'Bob       '
        PersonRecordH.new.generate.slice(10, 10).should eq 'Williams  '

        PersonRecordI.new.generate.slice(0, 10).should eq 'Bob       '
        PersonRecordI.new.generate.slice(10, 10).should eq 'Jacobs    '
      end
    end
  end

  context 'when a block is passed to field' do
    class PersonRecordJ < Fixy::Record
      include Fixy::Formatter::Alphanumeric
      set_record_length 20
      field(:description , 20, '1-20', :alphanumeric) { 'Use My Value' }
    end

    it 'uses the proc conversion as the field value' do
      PersonRecordJ.new.generate.should eq('Use My Value'.ljust(20) << "\n")
    end
  end

  context 'when setting a line ending' do
    class PersonRecordWithLineEnding < Fixy::Record
      include Fixy::Formatter::Alphanumeric
      set_record_length 20
      set_line_ending Fixy::Record::LINE_ENDING_CRLF
      field(:description , 20, '1-20', :alphanumeric) { 'Use My Value' }
    end

    it 'uses the given line ending' do
      PersonRecordWithLineEnding.new.generate.should eq('Use My Value'.ljust(20) << "\r\n")
    end
  end
end

describe 'Parsing a record' do
  let(:multibyte_record) { 'älimuk   Karil     ' }
  context 'with a record of multi-byte characters' do
    it 'should not raise with the right number of bytes' do
      PersonRecordE.parse(multibyte_record, true).should eq({
        record: File.read('spec/fixtures/debug_parsed_multibyte_record.txt'),
      fields: [
        { name: :first_name, value: 'älimuk   '},
        { name: :last_name,  value: 'Karil     '}
      ]
      })
    end

    it 'should not raise with the right amount' do
      expect {
        PersonRecordE.parse('älimuk  Karil     ', true)
      }.to raise_error(StandardError, 'Record length is invalid (Expected 20)')
    end
  end

  context 'with custom line endings' do
    let(:record) { "Use My Value        " }
    it 'should generate fixed width record' do
      PersonRecordWithLineEnding.parse(record).should eq({
        record: (record + Fixy::Record::LINE_ENDING_CRLF),
        fields: [
          { name: :description,  value: 'Use My Value        '}
        ]
      })
    end
  end

  context 'when properly defined' do
    let(:record) { "Sarah     Kerrigan  " }
    class PersonRecordK < Fixy::Record
      include Fixy::Formatter::Alphanumeric

      set_record_length 20

      field :first_name, 10, '1-10' , :alphanumeric
      field :last_name , 10, '11-20', :alphanumeric

      field_value :first_name, -> { 'Sarah' }

      def last_name
        'Kerrigan'
      end
    end

    it 'should generate fixed width record' do
      PersonRecordE.parse(record).should eq({
        record: (record + "\n"),
        fields: [
          { name: :first_name, value: 'Sarah     '},
          { name: :last_name,  value: 'Kerrigan  '}
        ]
      })
    end

    context 'when using the debug flag' do
      it 'should produce a debug log' do
        PersonRecordE.parse(record, true).should eq({
          record: File.read('spec/fixtures/debug_parsed_record.txt'),
          fields: [
            { name: :first_name, value: 'Sarah     '},
            { name: :last_name,  value: 'Kerrigan  '}
          ]
        })
      end
    end

    context 'when invalid record provided' do
      context 'with a non-string record type' do
        it 'should raise an error' do
          expect {
            PersonRecordE.parse(nil, true)
          }.to raise_error(StandardError, 'Record must be a string')
        end
      end

      context 'with an invalid record length' do
        it 'should raise an error' do
          expect {
            PersonRecordE.parse('', true)
          }.to raise_error(StandardError, 'Record length is invalid (Expected 20)')
        end
      end
    end
  end

  context 'when definition is incomplete (e.g. undefined columns)' do
    it 'should raise an error' do
      class PersonRecordL < Fixy::Record
        include Fixy::Formatter::Alphanumeric
        set_record_length 20
        field :first_name, 10, '1-10' , :alphanumeric
        field :last_name , 8,  '11-18', :alphanumeric
        field_value :first_name, -> { 'Sarah' }
        field_value :last_name,  -> { 'Kerrigan' }
      end

      expect {
        PersonRecordL.parse(' ' * 20)
      }.to raise_error(StandardError, "Undefined field for position 19")
    end
  end
end
