module Fixy
  module Formatter
    module Alphanumeric

      #
      # Alphanumeric Formatter
      #
      # Only contains printable characters and is
      # left-justified and filled with spaces.
      #

      def format_alphanumeric(input, byte_width)
        input_string = String.new(input.to_s).tr "#{self.class::LINE_ENDING_CRLF}#{line_ending}", ''
        result = ''

        if input_string.bytesize <= byte_width
          result << input_string
        else
          input_string.each_char do |char|
            if result.bytesize + char.bytesize <= byte_width
              result << char
            else
              break
            end
          end
        end

        result << ' ' * (byte_width - result.bytesize)
      end
    end
  end
end
