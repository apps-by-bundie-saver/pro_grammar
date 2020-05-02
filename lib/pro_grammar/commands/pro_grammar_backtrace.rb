# frozen_string_literal: true

class ProGrammar
  class Command
    class ProGrammarBacktrace < ProGrammar::ClassCommand
      match 'pro_grammar-backtrace'
      group 'Context'
      description 'Show the backtrace for the ProGrammar session.'

      banner <<-BANNER
        Usage: pro_grammar-backtrace [OPTIONS] [--help]

        Show the backtrace for the position in the code where ProGrammar was started. This can
        be used to infer the behavior of the program immediately before it entered ProGrammar,
        just like the backtrace property of an exception.

        NOTE: if you are looking for the backtrace of the most recent exception raised,
        just type: `_ex_.backtrace` instead.
        See: https://github.com/pro_grammar/pro_grammar/wiki/Special-Locals
      BANNER

      def process
        text = "#{bold('Backtrace:')}\n--\n#{pro_grammar_instance.backtrace.join("\n")}"
        pro_grammar_instance.pager.page(text)
      end
    end

    ProGrammar::Commands.add_command(ProGrammar::Command::ProGrammarBacktrace)
  end
end
