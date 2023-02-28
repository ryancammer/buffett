defmodule Kafkaesque.KafkaRoundTripSpec do
  use ESpec

  alias Kafkaesque.{
    Broker,
    Consumer,
    Gatherer,
    Kafka,
    KafkaDataConsumer,
    KeyCompletionCheck
  }

  describe "A successful round trip" do
    it "makes a round trip call" do
      Registry.start_link(:unique, Kafkaesque)

      {:ok, host_name} = :inet.gethostname

      message = "message" # todo: serialize some order json
      partition = 0
      topic = "completed_orders"

      kafka = Kafka.new(
        key: Atom.to_string(:completed_order),
        message: message,
        partition: partition,
        topic: topic
      )

      {:ok, agent} = Agent.start_link fn -> nil end

      coordinator = Gatherer.perform(
        completion_check: KeyCompletionCheck.new(completion_keys: [:product, :order]),
        actions: [kafka],
        completion_action: fn(data) -> Agent.update(agent, fn _ -> data end) end
      )

      order_data_topic = "order_data"

      order_response = Kafka.new(
        key: Atom.to_string(:order),
        message: "order data",
        partition: 0,
        topic: order_data_topic,
        node_name: host_name
      )

      product_response = Kafka.new(
        key: Atom.to_string(:product),
        message: "product data",
        partition: 0,
        topic: order_data_topic,
        node_name: host_name
      )

      offset = Broker.latest_offset(order_data_topic)

      order_response.(coordinator)
      product_response.(coordinator)

      consumer = Consumer.new(topic: order_data_topic, action: KafkaDataConsumer.new())

      consumer.(offset)

      result = Agent.get(agent, fn data -> data end)

      Agent.stop(agent)

      expect(result).to be(%{order: "order data", product: "product data"})
    end
  end
end
