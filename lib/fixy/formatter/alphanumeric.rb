module Fixy
  module Formatter
    module Alphanumeric

      #
      # Alphanumeric Formatter
      #
      # Only contains printable characters and is
      # left-justified and filled with spaces.
      #

      def format_alphanumeric(input, bytes)
        input_string = String.new(input.to_s)
        truncated_bytesize = [input_string.bytesize, bytes].min
        if truncated_bytesize < bytes
          input_string << " " * (bytes - truncated_bytesize)
          input_string
        else
          input_string.byteslice(0..(truncated_bytesize - 1))
        end
      end
    end
  end
end
