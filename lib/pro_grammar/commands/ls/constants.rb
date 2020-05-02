# frozen_string_literal: true

class ProGrammar
  class Command
    class Ls < ProGrammar::ClassCommand
      class Constants < ProGrammar::Command::Ls::Formatter
        DEPRECATED_CONSTANTS = [
          :Data, :Fixnum, :Bignum, :TimeoutError, :NIL, :FALSE, :TRUE
        ].tap do |constants|
          constants << :JavaPackageModuleTemplate if Helpers::Platform.jruby?
        end
        include ProGrammar::Command::Ls::Interrogatable

        def initialize(interrogatee, no_user_opts, opts, pro_grammar_instance)
          super(pro_grammar_instance)
          @interrogatee = interrogatee
          @no_user_opts = no_user_opts
          @default_switch = opts[:constants]
          @verbose_switch = opts[:verbose]
          @dconstants = opts.dconstants?
        end

        def correct_opts?
          super || (@no_user_opts && interrogating_a_module?)
        end

        def output_self
          mod = interrogatee_mod
          constants = WrappedModule.new(mod).constants(@verbose_switch)
          output_section('constants', grep.regexp[format(mod, constants)])
        end

        private

        def show_deprecated_constants?
          @dconstants == true
        end

        def format(mod, constants)
          constants.sort_by(&:downcase).map do |name|
            if Object.respond_to?(:deprecate_constant) &&
               DEPRECATED_CONSTANTS.include?(name) &&
               !show_deprecated_constants?
              next
            end

            if (const = (begin
                           !mod.autoload?(name) && (mod.const_get(name) || true)
                         rescue StandardError
                           nil
                         end))
              if begin
                   const < Exception
                 rescue StandardError
                   false
                 end
                color(:exception_constant, name)
              elsif begin
                      mod.const_get(name).is_a?(Module)
                    rescue StandardError
                      false
                    end
                color(:class_constant, name)
              else
                color(:constant, name)
              end
            else
              color(:unloaded_constant, name)
            end
          end
        end
      end
    end
  end
end
