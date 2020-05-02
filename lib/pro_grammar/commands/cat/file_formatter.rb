# frozen_string_literal: true

class ProGrammar
  class Command
    class Cat
      class FileFormatter < AbstractFormatter
        attr_reader :file_with_embedded_line
        attr_reader :opts
        attr_reader :pro_grammar_instance

        def initialize(file_with_embedded_line, pro_grammar_instance, opts)
          unless file_with_embedded_line
            raise CommandError, "Must provide a filename, --in, or --ex."
          end

          @file_with_embedded_line = file_with_embedded_line
          @opts = opts
          @pro_grammar_instance = pro_grammar_instance
          @code_from_file = ProGrammar::Code.from_file(file_name)
        end

        def format
          set_file_and_dir_locals(file_name, pro_grammar_instance, pro_grammar_instance.current_context)
          decorate(@code_from_file)
        end

        def file_and_line
          file_name, line_num = file_with_embedded_line.split(%r{:(?!/|\\)})

          [file_name, line_num ? line_num.to_i : nil]
        end

        private

        def file_name
          file_and_line.first
        end

        def line_number
          file_and_line.last
        end

        def code_window_size
          pro_grammar_instance.config.default_window_size || 7
        end

        def decorate(content)
          if line_number
            super(content.around(line_number, code_window_size))
          else
            super
          end
        end

        def code_type
          opts[:type] || detect_code_type_from_file(file_name)
        end

        def detect_code_type_from_file(file_name)
          code_type = @code_from_file.code_type

          if code_type == :unknown
            name = File.basename(file_name).split('.', 2).first
            case name
            when "Rakefile", "Gemfile"
              :ruby
            else
              :text
            end
          else
            code_type
          end
        end
      end
    end
  end
end
