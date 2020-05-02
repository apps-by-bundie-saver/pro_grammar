# frozen_string_literal: true

RSpec.describe ProGrammar::Tracer do
  describe "#initialize" do
  	it "raises an ArgumentError when invalid trace_type is passed as a param" do
  		expect(ProGrammar::Tracer.new(:dud, 0)).to raise_error(ArgumentError)
  	end
  end
end
