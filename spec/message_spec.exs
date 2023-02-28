defmodule Kafkaesque.MessageSpec do
  use ESpec

  alias Kafkaesque.Message

  describe "to_kafka_request" do
    let :expected_message do
      %KafkaEx.Protocol.Produce.Request{
        topic: topic(),
        partition: partition(),
        required_acks: 1,
        compression: :gzip,
        messages: [
          %KafkaEx.Protocol.Produce.Message{
            key: "#{node_name()}::#{process_name()}::#{key()}",
            value: message()
          }
        ]
      }
    end

    let :key, do: "product"

    let :message, do: "some message"

    let :node_name, do: "elixir-product-1"

    let :partition, do: 0

    let :process_name, do: "al9ek.sae0e-"

    let :topic, do: "products"

    subject do
      Message.to_kafka_request(
        topic: topic(),
        partition: partition(),
        message: message(),
        node_name: node_name(),
        process_name: process_name(),
        key: key()
      )
    end

    it "produces the expected message" do
      expect(subject()).to be(expected_message())
    end
  end
end
