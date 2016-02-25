require 'spec_helper'

describe Fixy::Formatter::UpcaseAscii do
  let(:proxy) do
    Class.new do
      LINE_ENDING_CRLF = "\r\n"
      def line_ending; end
      include Fixy::Formatter::UpcaseAscii
    end.new
  end
  let(:format) { -> (input, bytes) { proxy.format_upcase_ascii input, bytes } }

  it 'upcases characters' do
    expect(format['Sir Charles', 11]).to eq('SIR CHARLES')
  end

  it 'coerces nils' do
    expect(format[nil, 3]).to eq('   ')
  end
end
