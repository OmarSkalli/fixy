require 'spec_helper'

describe Fixy::Formatter::Ascii do
  let(:proxy) do
    Class.new do
      LINE_ENDING_CRLF = "\r\n"
      def line_ending; end
      include Fixy::Formatter::Ascii
    end.new
  end

  let(:format) { -> (input, bytes) { proxy.format_ascii input, bytes } }

  it 'transliterates not ascii characters' do
    expect(format['Sïr Chårles', 11]).to eq('Sir Charles')
  end

  it 'coerces nils' do
    expect(format[nil, 3]).to eq('   ')
  end
end
