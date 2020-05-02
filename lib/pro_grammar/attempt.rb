# frozen_string_literal: true

class ProGrammar
  class Attempt
  	attr_accessor :author
  	attr_accessor :description
  	attr_accessor :code
    attr_accessor :link

  	def initialize(author, description, code, start_trace, end_trace, error, link)
  		@author = author
  		@description = description
  		@code = code
  		@start_trace = start_trace
  		@end_trace = end_trace
  		@error = error
      @link = link
  	end
  end
end
