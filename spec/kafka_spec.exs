defmodule Kafkaesque.KafkaSpec do
  use ESpec

  alias Kafkaesque.{Broker, Kafka}

  describe "When the Kafka module is used to produce to a topic" do
    let :host_name, do: "host_name"

    let :key, do: "order"

    let :message, do: "10"

    let :process_name, do: "process_name"

    let :node_name do
      {:ok, name} = :inet.gethostname
      name
    end

    let :pid, do: self()

    let :expected_request do
      %KafkaEx.Protocol.Produce.Request{
        compression: :gzip,
        messages: [
          %KafkaEx.Protocol.Produce.Message{
            key: "#{node_name()}::#{process_name()}::#{key()}",
            value: message()
          }
        ],
        partition: 0,
        required_acks: 1,
        timeout: 0,
        topic: topic()
      }
    end

    let :topic, do: "completed_orders"

    subject do
      Kafka.new(
        key: key(),
        message: message(),
        partition: 0,
        topic: topic()
      )
    end

    before do
      allow Broker |> to(accept :produce, fn(_) -> true end)

      allow Registry |> to(accept :keys, fn(_, _) -> [process_name()] end)

      subject().(pid())
    end

    it "produces a request" do
      expect Broker |> to(accepted :produce, [expected_request()])
    end
  end
end
