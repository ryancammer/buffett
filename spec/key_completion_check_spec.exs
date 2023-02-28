defmodule Kafkaesque.KeyCompletionCheckSpec do
  use ESpec

  alias Kafkaesque.KeyCompletionCheck

  describe "When a key completion is checked" do
    let :completion_keys, do: [:product, :order]

    subject do
      KeyCompletionCheck.new(completion_keys: completion_keys())
    end

    describe "when it is not complete" do
      let :data, do: %{:product => []}

      it "is false" do
        expect(subject().(data())).to be(false)
      end
    end

    describe "when it is complete" do
      let :data, do: %{:order => [], :product => []}

      it "is true" do
        expect(subject().(data())).to be(true)
      end
    end
  end
end
