defmodule Kafkaesque.BrokerSpec do
  use ESpec

  alias Kafkaesque.Broker

  let :topic, do: "The topic"

  describe "#produce" do
    let :message, do: "The message"

    before do
      allow KafkaEx |> to(accept :produce, fn(_, _, _) -> true end)
      Broker.produce(message(), topic())
    end

    it "produces a message to a topic in Kafka" do
      expect KafkaEx |> to(accepted :produce, [message(), 0, topic()])
    end
  end

  describe "#fetch" do
    let :offset_response do
      [
        %KafkaEx.Protocol.Offset.Response{
          partition_offsets: [
            %{
              error_code: :no_error,
              offset: [1],
              partition: 0
            }
          ],
          topic: "t1"
        }
      ]
    end

    let :message do
      %KafkaEx.Protocol.Fetch.Message{
        attributes: 0,
        crc: 4191946705,
        key: "",
        offset: 0,
        value: "some value"
      }
    end

    let :fetch_response do
      [
        %KafkaEx.Protocol.Fetch.Response{
          partitions: [
            %{
              error_code: :no_error,
              hw_mark_offset: 1,
              last_offset: 0,
              message_set: [message()],
              partition: 0
            }
          ],
          topic: "t1"
        }
      ]
    end

    subject do: Broker.fetch(topic())

    before do
      allow KafkaEx |> to(accept :latest_offset, fn(_, _) -> offset_response() end)
      allow KafkaEx |> to(accept :fetch, fn(_, _, _) -> fetch_response() end)
    end

    it "consumes messages from a topic in Kafka" do
      expect(subject()).to be([message()])
    end
  end
end
