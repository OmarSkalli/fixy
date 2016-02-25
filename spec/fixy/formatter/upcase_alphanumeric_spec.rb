require 'spec_helper'

describe Fixy::Formatter::UpcaseAlphanumeric do
  let(:proxy) do
    Class.new do
      LINE_ENDING_CRLF = "\r\n"
      def line_ending; end
      include Fixy::Formatter::UpcaseAlphanumeric
    end.new
  end
  let(:format) { -> (input, bytes) { proxy.format_upcase_alphanumeric input, bytes } }

  it 'upcases characters' do
    expect(format['Sir Charles 34', 14]).to eq('SIR CHARLES 34')
  end

  it 'coerces nils' do
    expect(format[nil, 3]).to eq('   ')
  end
end
