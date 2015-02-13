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
        result = ''

        if input.bytesize <= byte_width
          result = input.dup
        else
          input.each_char do |char|
            if result.bytesize + char.bytesize <= byte_width
              result << char
            else
              break
            end
          end
        end

        result << " " * (byte_width - result.bytesize)
      end
    end
  end
end
