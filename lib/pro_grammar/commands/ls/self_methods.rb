# frozen_string_literal: true

class ProGrammar
  class Command
    class Ls < ProGrammar::ClassCommand
      class SelfMethods < ProGrammar::Command::Ls::Formatter
        include ProGrammar::Command::Ls::Interrogatable
        include ProGrammar::Command::Ls::MethodsHelper

        def initialize(interrogatee, no_user_opts, opts, pro_grammar_instance)
          super(pro_grammar_instance)
          @interrogatee = interrogatee
          @no_user_opts = no_user_opts
          @ppp_switch = opts[:ppp]
          @jruby_switch = opts['all-java']
        end

        def output_self
          methods = all_methods(true).select do |m|
            m.owner == @interrogatee && grep.regexp[m.name]
          end
          heading = "#{ProGrammar::WrappedModule.new(@interrogatee).method_prefix}methods"
          output_section(heading, format(methods))
        end

        private

        def correct_opts?
          @no_user_opts && interrogating_a_module?
        end
      end
    end
  end
end
