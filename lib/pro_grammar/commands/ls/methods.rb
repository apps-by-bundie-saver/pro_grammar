# frozen_string_literal: true

class ProGrammar
  class Command
    class Ls < ProGrammar::ClassCommand
      class Methods < ProGrammar::Command::Ls::Formatter
        include ProGrammar::Command::Ls::Interrogatable
        include ProGrammar::Command::Ls::MethodsHelper

        def initialize(interrogatee, no_user_opts, opts, pro_grammar_instance)
          super(pro_grammar_instance)
          @interrogatee = interrogatee
          @no_user_opts = no_user_opts
          @default_switch = opts[:methods]
          @instance_methods_switch = opts['instance-methods']
          @ppp_switch = opts[:ppp]
          @jruby_switch = opts['all-java']
          @quiet_switch = opts[:quiet]
          @verbose_switch = opts[:verbose]
        end

        def output_self
          methods = all_methods.group_by(&:owner)
          # Reverse the resolution order so that the most useful information
          # appears right by the prompt.
          resolution_order.take_while(&below_ceiling).reverse.map do |klass|
            methods_here = (methods[klass] || []).select { |m| grep.regexp[m.name] }
            heading = "#{ProGrammar::WrappedModule.new(klass).method_prefix}methods"
            output_section(heading, format(methods_here))
          end.join('')
        end

        private

        def correct_opts?
          super || @instance_methods_switch || @ppp_switch || @no_user_opts
        end

        # Get a lambda that can be used with `take_while` to prevent over-eager
        # traversal of the Object's ancestry graph.
        def below_ceiling
          ceiling = if @quiet_switch
                      [ProGrammar::Method.safe_send(interrogatee_mod, :ancestors)[1]] +
                        pro_grammar_instance.config.ls.ceiling
                    elsif @verbose_switch
                      []
                    else
                      pro_grammar_instance.config.ls.ceiling.dup
                    end
          ->(klass) { !ceiling.include?(klass) }
        end
      end
    end
  end
end
