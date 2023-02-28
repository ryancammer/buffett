defmodule Kafkaesque.KafkaDataConsumerSpec do
  use ESpec

  alias Kafkaesque.{Coordinator, KafkaDataConsumer}

  describe "When data is provided" do
    let :data do
      [
        %KafkaEx.Protocol.Produce.Message{
          key: "#{node_name()}::#{process_name()}::#{Atom.to_string(key())}",
          value: message()
        }
      ]
    end

    let :key, do: :some_key

    let :message, do: "message"

    let :node_name, do: "some_node"

    let :pid, do: self()

    let :process_name, do: "some_process"

    subject do: KafkaDataConsumer.new()

    before do
      allow Registry |> to(accept :lookup, fn(_, _) -> [{pid(), :ok}] end)

      allow Coordinator |> to(accept :append, fn(_, _, _) -> true end)
    end

    it "sends the coordinator the message" do
      subject().(data())
      expect Coordinator |> to(accepted :append, [pid(), key(), message()])
    end
  end
end
