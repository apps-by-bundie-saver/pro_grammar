# frozen_string_literal: true

class ProGrammar
  class Command
    class ShowInput < ProGrammar::ClassCommand
      match 'show-input'
      group 'Editing'
      description 'Show the contents of the input buffer for the current ' \
                  'multi-line expression.'

      banner <<-'BANNER'
        Show the contents of the input buffer for the current multi-line expression.
      BANNER

      def process
        output.puts Code.new(eval_string).with_line_numbers
      end
    end

    ProGrammar::Commands.add_command(ProGrammar::Command::ShowInput)
  end
end
