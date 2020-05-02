# frozen_string_literal: true

class ProGrammar
  class Evaluation
    attr_accessor :eval_type
    attr_accessor :eval_result

  	def initialize(pro_grammar_instance, eval_type=nil, eval_result=nil)
  		@pro_grammar = pro_grammar_instance
  		@eval_type = eval_type
  		@eval_result = eval_result
  	end

  	def evaluate_code(line)
			line = line.gsub(/(\e\[[\d+;]*\d+m[\d+]*:*|\[[\d+]+m*)/, '')
      conditional_found = line.match(/[\ \t\n\r]*(if|unless|elsif|case|when|while|for|until)\ ([\:+\"+|\'+|\w+|\_+]+)/)
      assignment_found = line.match(/[^\ \t\n\r]*[\ \t\n\r]*(@+[\w|\_]+)\ +=\ +(.+)/)
      begin
        if conditional_found
        	r_check = line.match(/[\ \t\n\r]*(if|unless|elsif|case|when|while|for|until)\ ([\:+\"+|\'+|\w+|\_+]+)\ *==\ *([\:+\"+|\'+|\w+|\_+]+)/)[3]
          unless r_check.nil?
          	result = @pro_grammar.evaluate_ruby(line.match(/[\ \t\n\r]*(if|unless|elsif|case|when|while|for|until)\ ([\:+\"+|\'+|\w+|\_+]+)/)[2]).nil? ? 'nil' : @pro_grammar.evaluate_ruby((line.match(/[\ \t\n\r]*(if|unless|elsif|case|when|while|for|until)\ ([\:+\"+|\'+|\w+|\_+]+)/)[2] == r_check).to_s)
	          self.eval_type = ProGrammar::Eval::Conditional.new(line)
	          self.eval_result = result
	          return "#{self.eval_type} #{self.eval_result}"
          else
	          result = @pro_grammar.evaluate_ruby(line.match(/[\ \t\n\r]*(if|unless|elsif|case|when|while|for|until)\ ([\:+\"+|\'+|\w+|\_+]+)/)[2]).nil? ? 'nil' : @pro_grammar.evaluate_ruby(line.match(/[\ \t\n\r]*(if|unless|elsif|case|when|while|for|until)\ ([\:+\"+|\'+|\w+|\_+]+)/)[2])
	          self.eval_type = ProGrammar::Eval::Conditional.new(line)
	          self.eval_result = result
	          return "#{self.eval_type} #{self.eval_result}"
	        end
        elsif assignment_found
          result = @pro_grammar.evaluate_ruby(line).nil? ? 'nil' : @pro_grammar.evaluate_ruby(line)
          self.eval_type = ProGrammar::Eval::Var.new(line)
          self.eval_result = result
          return "#{self.eval_type} #{self.eval_result}"
        end
      rescue Exception => e
        if conditional_found
          self.eval_type = ProGrammar::Eval::Conditional.new(line)
          self.eval_result = e
          return "#{self.eval_type} #{self.eval_result}"
        elsif assignment_found
          self.eval_type = ProGrammar::Eval::Var.new(line)
          self.eval_result = e
          return "#{self.eval_type} #{self.eval_result}"
        end
      end
      return false
  	end
  end
end