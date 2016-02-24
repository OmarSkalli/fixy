module Fixy
  module Formatter
    module Ascii
      include Fixy::Formatter::Alphanumeric

      #
      # ASCII Formatter
      #
      # Same as Alphanumeric Formatter, except
      # it transliterates characters not in ASCII to ASCII
      #

      def format_ascii(input, bytes)
        format_alphanumeric(I18n.transliterate(input.to_s, replacement: '').gsub(/\s/, ' ').chomp, bytes)
      end
    end
  end
end
