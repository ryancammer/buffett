defmodule Kafkaesque.CoordinatorSpec do
  use ESpec

  alias Kafkaesque.Coordinator

  describe "The completion of the coordinator" do
    let :completion_action, do: fn(_data) -> :complete end

    let :completion_check, do: fn(data) -> Map.has_key?(data, :product) end

    let :initial_action, do: fn(data) -> data end

    let :coordinator do
      Coordinator.new(
        initial_action: initial_action(),
        completion_check: completion_check(),
        completion_action: completion_action()
      )
    end

    let :data_to_append, do: %{id: 1}

    subject do: Coordinator.append(coordinator(), data_key(), data_to_append())

    context "When the data is complete" do
      let :data_key, do: :product

      it "Returns a message indicating completion" do
        expect(subject()).to be(%{complete: true})
      end
    end

    context "When the data is not complete" do
      let :data_key, do: :order

      it "Returns a message indicating that the data is not complete" do
        expect(subject()).to be(%{complete: false})
      end
    end
  end
end
