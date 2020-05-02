# frozen_string_literal: true

class ProGrammar
  class Command
    class Ls < ProGrammar::ClassCommand
      class Formatter
        attr_writer :grep
        attr_reader :pro_grammar_instance

        def initialize(pro_grammar_instance)
          @pro_grammar_instance = pro_grammar_instance
          @target = pro_grammar_instance.current_context
          @default_switch = nil
        end

        def write_out
          return false unless correct_opts?

          output_self
        end

        private

        def color(type, str)
          ProGrammar::Helpers::Text.send pro_grammar_instance.config.ls.send("#{type}_color"), str
        end

        # Add a new section to the output.
        # Outputs nothing if the section would be empty.
        def output_section(heading, body)
          return '' if body.compact.empty?

          fancy_heading = ProGrammar::Helpers::Text.bold(color(:heading, heading))
          ProGrammar::Helpers.tablify_or_one_line(fancy_heading, body, @pro_grammar_instance)
        end

        def format_value(value)
          ProGrammar::ColorPrinter.pp(value, ''.dup)
        end

        def correct_opts?
          @default_switch
        end

        def output_self
          raise NotImplementedError
        end

        def grep
          @grep || proc { |x| x }
        end
      end
    end
  end
end
