module Fixy
  class Record
    class << self
      def set_record_length(count)
        define_singleton_method('record_length') { count }
      end

      def field(name, size, range, type)
        @record_fields ||= default_record_fields
        range_matches = range.match /^(\d+)(?:-(\d+))?$/

        # Make sure inputs are valid, we rather fail early than behave unexpectedly later.
        raise ArgumentError, "Name '#{name}' is not a symbol"  unless name.is_a? Symbol
        raise ArgumentError, "Size '#{size}' is not a numeric" unless size.is_a?(Numeric) && size > 0
        raise ArgumentError, "Range '#{range}' is invalid"     unless range_matches
        raise ArgumentError, "Unknown type '#{type}'"          unless (private_instance_methods + instance_methods).include? "format_#{type}".to_sym

        # Validate the range is consistent with size
        range_from  = Integer(range_matches[1])
        range_to    = Integer(range_matches[2].nil? ? range_matches[1] : range_matches[2])
        valid_range = (range_from + (size - 1) == range_to)

        raise ArgumentError, "Invalid Range (size: #{size}, range: #{range})" unless valid_range
        raise ArgumentError, "Invalid Range (> #{record_length})"             unless range_to <= record_length

        # Ensure range is not already covered by another definition
        (1..range_to).each do |column|
          if @record_fields[column] && @record_fields[column][:to] >= range_from
            raise ArgumentError, "Column #{column} has already been allocated"
          end
        end

        # We're good to go :)
        @record_fields[range_from] = { name: name, from: range_from, to: range_to, size: size, type: type}

        field_value(name, Proc.new) if block_given?
      end

      # Convenience method for creating field methods
      def field_value(name, value)

        # Make sure we're not overriding an existing method
        if (private_instance_methods + instance_methods).include?(name)
          raise ArgumentError, "Method '#{name}' is already defined, watch out for conflicts."
        end

        if value.is_a? Proc
          define_method(name) { self.instance_exec(&value) }
        else
          define_method(name) { value }
        end
      end

      def record_fields
        @record_fields
      end

      def default_record_fields
        if superclass.respond_to?(:record_fields, true) && superclass.record_fields
          superclass.record_fields.dup
        else
          {}
        end
      end
    end

    attr_accessor :debug_mode

    # Generate the entry based on the record structure
    def generate(debug = false)
      @debug_mode = debug
      output = ''
      current_position = 1
      current_record = 1

      while current_position <= self.class.record_length do

        field = record_fields[current_position]
        raise StandardError, "Undefined field for position #{current_position}" unless field

        # We will first retrieve the value, then format it
        method          = field[:name]
        value           = send(method)
        formatted_value = format_value(value, field[:size], field[:type])
        formatted_value = decorator.field(formatted_value, current_record, current_position, method, field[:size], field[:type])

        output << formatted_value
        current_position = field[:to] + 1
        current_record += 1
      end

      # Documentation mandates that every record ends with new line.
      output << "\n"

      # All ready. In the words of Mr. Peters: "Take it and go!"
      decorator.record(output)
    end

    private

    # Format value with user defined formatters.
    def format_value(value, size, type)
      send("format_#{type}".to_sym, value, size)
    end

    # Retrieves the list of record fields that were set through the class methods.
    def record_fields
      self.class.record_fields
    end

    def decorator
      debug_mode ? Fixy::Decorator::Debug : Fixy::Decorator::Default
    end
  end
end
