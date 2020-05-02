# frozen_string_literal: true

class ProGrammar
  class Command
    class Ls < ProGrammar::ClassCommand
      class LocalNames < ProGrammar::Command::Ls::Formatter
        def initialize(no_user_opts, args, pro_grammar_instance)
          super(pro_grammar_instance)
          @no_user_opts = no_user_opts
          @args = args
          @sticky_locals = pro_grammar_instance.sticky_locals
        end

        def correct_opts?
          super || (@no_user_opts && @args.empty?)
        end

        def output_self
          local_vars = grep.regexp[@target.eval('local_variables')]
          output_section('locals', format(local_vars))
        end

        private

        def format(locals)
          locals.sort_by(&:downcase).map do |name|
            if @sticky_locals.include?(name.to_sym)
              color(:pro_grammar_var, name)
            else
              color(:local_var, name)
            end
          end
        end
      end
    end
  end
end
