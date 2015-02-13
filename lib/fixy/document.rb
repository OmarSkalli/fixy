module Fixy
  class Document

    attr_accessor :content, :debug_mode

    def generate_to_file(path, debug = false)
      File.open(path, 'w') do |file|
        file.write(generate(debug))
      end
    end

    def generate(debug = false)
      @debug_mode = debug
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
      @content = record.generate(debug_mode) << @content
    end

    def append_record(record)
      @content << record.generate(debug_mode)
    end

    def parse_record(klass, record)
      @content << klass.parse(record, debug_mode)[:record]
    end
  end
end
