module Fixy
  module Decorator
    class Default
      class << self
        def document(document)
          document
        end

        def field(value, record_number, position, method, length, type)
          value
        end

        def record(record)
          record
        end
      end
    end
  end
end
