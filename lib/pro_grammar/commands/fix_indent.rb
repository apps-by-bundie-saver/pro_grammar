# frozen_string_literal: true

class ProGrammar
  class Command
    class FixIndent < ProGrammar::ClassCommand
      match 'fix-indent'
      group 'Input and Output'

      description "Correct the indentation for contents of the input buffer"

      banner <<-USAGE
        Usage: fix-indent
      USAGE

      def process
        indented_str = ProGrammar::Indent.indent(eval_string)
        pro_grammar_instance.eval_string = indented_str
      end
    end

    ProGrammar::Commands.add_command(ProGrammar::Command::FixIndent)
  end
end
