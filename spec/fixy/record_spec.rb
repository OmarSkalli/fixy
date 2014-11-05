require 'spec_helper'

describe 'Defining a Record' do
  context 'when the definition is correct' do
    it 'should not raise any exception' do
      expect {
        class PersonRecord < Fixy::Record
          include Fixy::Formatter::Alphanumeric

          set_record_length 20

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
    it 'should generate fixed width record' do
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

      PersonRecordE.new.generate.should eq "Sarah     Kerrigan  \n"
      PersonRecordE.new.generate(true).should eq File.read('spec/fixtures/debug_record.txt')
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
    it 'should include fields from the superclass' do
      class PersonRecordG < Fixy::Record
        include Fixy::Formatter::Alphanumeric
        set_record_length 20

        field :first_name, 10, '1-10' , :alphanumeric
        field_value :first_name, -> { 'Parent' }
      end

      class PersonRecordH < PersonRecordG
        include Fixy::Formatter::Alphanumeric
        set_record_length 20
        field :last_name , 10,  '11-20', :alphanumeric
        field_value :last_name,  -> { 'Child' }
      end

      PersonRecordH.new.generate.slice(0, 10).should eq 'Parent    '
      PersonRecordH.new.generate.slice(10, 10).should eq 'Child     '
    end
  end
end