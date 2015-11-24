module Fixy
  module Formatter
    module Literal
      include Fixy::Formatter::Alphanumeric

      def format_literal(input, byte_width)
        format_alphanumeric( input, byte_width )
      end

      def parse_literal( value )
        value
      end
    end
  end
end
