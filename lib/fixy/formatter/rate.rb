module Fixy
  module Formatter
    module Rate

      include Fixy::Formatter::Helpers

      #
      # Rate Formatter
      #
      # May contain any digit from 0 through 9. Field is unsigned, has
      # an implied decimal between positions 2 and 3, and is
      # right-justified and zero-filled. For example, 1.45% would
      # be coded as 0145000.
      #

      def format_rate(input, length)
        raise ArgumentError, "Invalid rate (rate: #{input}. Rate must be >= 0." if input < 0
        (('%0' << length.to_s << 'd') % integerize(input * (10 ** length)))[0..(length - 1)]
      end
    end
  end
end
