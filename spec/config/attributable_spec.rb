# frozen_string_literal: true

RSpec.describe ProGrammar::Config::Attributable do
  subject { klass.new }

  describe "#attribute" do
    let(:klass) do
      Class.new do
        extend ProGrammar::Config::Attributable
        attribute :foo
      end
    end

    it "creates a reader attribute for the given name" do
      expect(klass.instance_method(:foo)).to be_a(UnboundMethod)
    end

    it "creates a writer attribute for the given name" do
      expect(klass.instance_method(:foo=)).to be_a(UnboundMethod)
    end

    context "and when the attribute is invoked" do
      it "sends the 'call' message to the value" do
        expect_any_instance_of(ProGrammar::Config::Value).to receive(:call)
        subject.foo
      end
    end
  end
end
