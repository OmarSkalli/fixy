module Fixy
  module Formatter
    module Helpers

      def integerize(input)
        if input.respond_to?(:round)
          input.round.to_i
        else
          input.to_i
        end
      end

    end
  end
end
