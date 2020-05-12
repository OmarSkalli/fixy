module Fixy
  class Record
    LINE_ENDING_LF = "\n".freeze
    LINE_ENDING_CR = "\r".freeze
    LINE_ENDING_CRLF = "#{LINE_ENDING_CR}#{LINE_ENDING_LF}".freeze
    DEFAULT_LINE_ENDING = LINE_ENDING_LF

    class << self
      def set_record_length(count)
        define_singleton_method('record_length') { count }
      end

      def set_line_ending(character)
        @line_ending = character
      end

      def field(name, size, range, type, &block)
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

        field_value(name, nil, &block) if block_given?
      end

      # Convenience method for creating field methods
      def field_value(name, value, &block)

        # Make sure we're not overriding an existing method
        if (private_instance_methods + instance_methods).include?(name)
          raise ArgumentError, "Method '#{name}' is already defined, watch out for conflicts."
        end

        if block_given?
          define_method(name, &block)
        elsif value.is_a?(Proc)
          define_method(name, &value)
        else
          define_method(name) { value }
        end
      end

      def record_fields
        @record_fields
      end

      def line_ending
        # Use the default line ending unless otherwise specified
        @line_ending || DEFAULT_LINE_ENDING
      end

      def default_record_fields
        if superclass.respond_to?(:record_fields, true) && superclass.record_fields
          superclass.record_fields.dup
        else
          {}
        end
      end

      # Parse an existing record
      def parse(record, debug = false)
        raise ArgumentError, 'Record must be a string'  unless record.is_a? String

        unless record.bytesize == record_length
          raise ArgumentError, "Record length is invalid (Expected #{record_length})"
        end

        decorator = debug ? Fixy::Decorator::Debug : Fixy::Decorator::Default
        fields = []
        output = ''
        current_position = 1
        current_record = 1

        byte_record = record.bytes.to_a
        while current_position <= record_length do

          field = record_fields[current_position]
          raise StandardError, "Undefined field for position #{current_position}" unless field

          # Extract field data from existing record
          from   = field[:from] - 1
          to     = field[:to]   - 1
          method = field[:name]
          value  = byte_record[from..to].pack('C*').force_encoding('utf-8')

          formatted_value = decorator.field(value, current_record, current_position, method, field[:size], field[:type])
          output << formatted_value
          fields << { name:  method, value: value }

          current_position = field[:to] + 1
          current_record += 1
        end

        # Documentation mandates that every record ends with new line.
        output << line_ending

        { fields: fields, record: decorator.record(output) }
      end
    end

    # Generate the entry based on the record structure
    def generate(debug = false)
      decorator = debug ? Fixy::Decorator::Debug : Fixy::Decorator::Default
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
      output << line_ending

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

    # Retrieves the line ending for this record type
    def line_ending
      self.class.line_ending
    end
  end
end
