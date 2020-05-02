# frozen_string_literal: true

class ProGrammar
  class BasicObject < BasicObject
    [:Kernel, :File, :Dir, :LoadError, :ENV, :ProGrammar].each do |constant|
      const_set constant, ::Object.const_get(constant)
    end
    include Kernel
  end
end
