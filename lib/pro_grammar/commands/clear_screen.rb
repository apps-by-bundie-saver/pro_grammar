# frozen_string_literal: true

class ProGrammar
  class Command
    class ClearScreen < ProGrammar::ClassCommand
      match 'clear-screen'
      group 'Input and Output'
      description 'Clear the contents of the screen/window ProGrammar is running in.'

      def process
        if ProGrammar::Helpers::Platform.windows?
          pro_grammar_instance.config.system.call(pro_grammar_instance.output, 'cls', pro_grammar_instance)
        else
          pro_grammar_instance.config.system.call(pro_grammar_instance.output, 'clear', pro_grammar_instance)
        end
      end
      ProGrammar::Commands.add_command(self)
    end
  end
end
