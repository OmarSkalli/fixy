module Fixy
  module Formatter
    module Sign
      SIGN_PLUS = '+'.freeze
      SIGN_MINUS = '-'.freeze

      include Fixy::Formatter::Helpers

      #
      # Sign Formatter
      # Accepts ether a `String` containing a sign '+' or '-', or a number.
      # Returns '+' for a positive amount or '-' for a negative amount.
      #

      def format_sign(input, length)
        raise ArgumentError, "Invalid length for a sign, must be 1 (got #{length})" if length != 1

        if input.is_a?(String)
          raise ArgumentError, "Invalid input, expected '+' or '-' but got #{input}" unless [SIGN_PLUS, SIGN_MINUS].include?(input)
          input
        else
          input < 0 ? SIGN_MINUS : SIGN_PLUS
        end
      end
    end
  end
end
