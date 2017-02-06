require 'spec_helper'

describe 'Defining a Document' do
  context 'when a build action is not defined' do
    it 'should raise an exception' do
      expect {
        Fixy::Document.new.generate
      }.to raise_error(NotImplementedError)
    end
  end

  context 'when a build action is defined' do
    class IdentityRecord < Fixy::Record
      set_record_length 20
      include Fixy::Formatter::Alphanumeric
      field :first_name, 10, '1-10' , :alphanumeric
      field :last_name , 10, '11-20', :alphanumeric

      def initialize(first_name, last_name)
        @first_name = first_name
        @last_name  = last_name
      end

      field_value :first_name, -> { @first_name }
      field_value :last_name , -> { @last_name  }
    end

    class PeopleDocument < Fixy::Document
      def build
        append_record  IdentityRecord.new('Sarah', 'Kerrigan')
        append_record  IdentityRecord.new('Jim', 'Raynor')
        prepend_record IdentityRecord.new('Arcturus', 'Mengsk')
      end
    end

    class ParsedPeopleDocument < Fixy::Document
      def build
        parse_record IdentityRecord, 'Arcturus  Mengsk    '
        parse_record IdentityRecord, 'Sarah     Kerrigan  '
        parse_record IdentityRecord, 'Jim       Raynor    '
      end
    end

    it 'should generate fixed width document' do
      PeopleDocument.new.generate.should eq "Arcturus  Mengsk    \nSarah     Kerrigan  \nJim       Raynor    \n"
      PeopleDocument.new.generate(true).should eq File.read('spec/fixtures/debug_document.txt')
    end

    it 'should parse fixed width document' do
      ParsedPeopleDocument.new.generate.should eq "Arcturus  Mengsk    \nSarah     Kerrigan  \nJim       Raynor    \n"
      ParsedPeopleDocument.new.generate(true).should eq File.read('spec/fixtures/debug_document.txt')
    end

    it 'should apply custom line endings if given' do
      ParsedPeopleDocument.new.generate(false, "\r\n").should eq "Arcturus  Mengsk    \r\nSarah     Kerrigan  \r\nJim       Raynor    \r\n"
      ParsedPeopleDocument.new.generate(true, "\r\n").should eq File.read('spec/fixtures/debug_document_custom_line_endings.txt')
    end
  end
end
