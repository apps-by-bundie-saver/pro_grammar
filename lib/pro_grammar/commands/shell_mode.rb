# frozen_string_literal: true

class ProGrammar
  class Command
    class ShellMode < ProGrammar::ClassCommand
      match 'shell-mode'
      group 'Input and Output'
      description 'Toggle shell mode. Bring in pwd prompt and file completion.'

      banner <<-'BANNER'
        Toggle shell mode. Bring in pwd prompt and file completion.
      BANNER

      def process
        state.disabled ^= true

        if state.disabled
          state.prev_prompt = pro_grammar_instance.prompt
          pro_grammar_instance.prompt = ProGrammar::Prompt[:shell]
        else
          pro_grammar_instance.prompt = state.prev_prompt
        end
      end
    end

    ProGrammar::Commands.add_command(ProGrammar::Command::ShellMode)
    ProGrammar::Commands.alias_command 'file-mode', 'shell-mode'
  end
end
