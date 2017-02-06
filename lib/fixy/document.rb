module Fixy
  class Document

    attr_accessor :content, :debug_mode, :line_ending

    def generate_to_file(path, debug = false)
      File.open(path, 'w') do |file|
        file.write(generate(debug))
      end
    end

    def generate(debug = false, line_ending = "\n")
      @debug_mode = debug
      @line_ending = line_ending
      @content = ''

      # Generate document based on user logic.
      build

      decorator.document(@content)
    end

    private

    def build
      raise NotImplementedError
    end

    def decorator
      debug_mode ? Fixy::Decorator::Debug : Fixy::Decorator::Default
    end

    def prepend_record(record)
      @content = record.generate(debug_mode, line_ending) << @content
    end

    def append_record(record)
      @content << record.generate(debug_mode, line_ending)
    end

    def parse_record(klass, record)
      @content << klass.parse(record, debug_mode, line_ending)[:record]
    end
  end
end
