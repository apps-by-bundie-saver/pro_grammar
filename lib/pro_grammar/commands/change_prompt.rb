# frozen_string_literal: true

class ProGrammar
  class Command
    class ChangePrompt < ProGrammar::ClassCommand
      match 'change-prompt'
      group 'Input and Output'
      description 'Change the current prompt.'
      command_options argument_required: true
      banner <<-BANNER
        Usage: change-prompt [OPTIONS] [NAME]

        Change the current prompt.
      BANNER

      def options(opt)
        opt.on(:l, :list, 'List the available prompts')
      end

      def process(prompt)
        if opts.present?(:l)
          list_prompts
        else
          change_prompt(prompt)
        end
      end

      private

      def list_prompts
        prompts = ProGrammar::Prompt.all.map do |name, prompt|
          "#{bold(name)}#{red(' (selected)') if pro_grammar_instance.prompt == prompt}\n" +
            prompt.description
        end
        output.puts(prompts.join("\n" * 2))
      end

      def change_prompt(prompt)
        if ProGrammar::Prompt[prompt]
          pro_grammar_instance.prompt = ProGrammar::Prompt[prompt]
        else
          raise ProGrammar::CommandError,
                "'#{prompt}' isn't a known prompt. Run `change-prompt --list` " \
                "to see the list of known prompts."
        end
      end

      ProGrammar::Commands.add_command(self)
    end
  end
end
