module Fixy
  module Formatter
    module SignedAmount
      include Fixy::Formatter::Amount

      #
      # Signed Amount Formatter
      #
      # Same as Amount, except it will append a '+' or '-'
      # based on the value.
      #

      def format_signed_amount(input, length)
        sign = input >= 0 ? '+' : '-'
        format_amount(input, length - 1) << sign
      end
    end
  end
end
