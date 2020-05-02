# frozen_string_literal: true

class ProGrammar
  class Command
    class Edit
      class ExceptionPatcher
        attr_accessor :pro_grammar_instance
        attr_accessor :state
        attr_accessor :file_and_line

        def initialize(pro_grammar_instance, state, exception_file_and_line)
          @pro_grammar_instance = pro_grammar_instance
          @state = state
          @file_and_line = exception_file_and_line
        end

        # perform the patch
        def perform_patch
          file_name, = file_and_line
          lines = state.dynamical_ex_file || File.read(file_name)

          source = ProGrammar::Editor.new(pro_grammar_instance).edit_tempfile_with_content(lines)
          pro_grammar_instance.evaluate_ruby source
          state.dynamical_ex_file = source.split("\n")
        end
      end
    end
  end
end
