defmodule Kafkaesque.GathererSpec do
  use ESpec

  alias Kafkaesque.{
    Broker,
    Coordinator,
    Gatherer,
    KeyCompletionCheck,
    Kafka,
    Rest
  }

  describe "When there are two rest endpoints that require coordination" do
    let :product_endpoint, do: "http://jsonplaceholder.typicode.com/posts"

    let :order_endpoint, do: "http://jsonplaceholder.typicode.com/posts"

    let :completion_check do
      KeyCompletionCheck.new(completion_keys: [:product, :order])
    end

    let :actions do
      [
        Rest.new(
          key: :product,
          url: product_endpoint(),
          appender: Coordinator
        ),
        Rest.new(
          key: :order,
          url: order_endpoint(),
          appender: Coordinator
        )
      ]
    end

    let :response do
      %HTTPotion.Response{
        body: "{\n  \"args\": {}, \n \"a\": \"1\", \n  \"b\": \"2\"\n}\n"
      }
    end

    let :expected do
      %{order: %{"a" => "1", "args" => %{}, "b" => "2"},
        product: %{"a" => "1", "args" => %{}, "b" => "2"}}
    end

    before do
      allow HTTPotion |> to(accept :request, fn(_, _, _) -> response() end)
    end

    it "gathers the data" do
      {:ok, agent} = Agent.start_link fn -> nil end

      Gatherer.perform(
        completion_check: completion_check(),
        actions: actions(),
        completion_action:
          fn(data) -> Agent.update(agent, fn _ -> data end) end
      )

      result = Agent.get(agent, fn data -> data end)

      Agent.stop(agent)

      expect(result).to be(expected())
    end

    it "supports a timeout" do

    end
  end

  describe "When the Gatherer has executed, but no data has come back" do
    before do
      allow Broker |> to(accept :produce, fn(_) -> :ok end)
      allow Kafka |> to(accept :perform, fn(pid, _) -> pid end)
    end

    let :actions do
      [
        Kafka.new(
          key: Atom.to_string(:order),
          message: "#{order_id()}",
          partition: 0,
          topic: "completed_orders"
        )
      ]
    end

    let :order_id, do: 10

    let :process_name, do: "process_name"

    let :node_name, do: "node_name"

    let :completion_check do
      KeyCompletionCheck.new(completion_keys: [:product, :order])
    end

    it "gathers the data" do
      Gatherer.perform(
        completion_check: completion_check(),
        actions: actions(),
        completion_action: fn(data) -> data end
      )

      expect Broker |> to(accepted :produce)
    end

    it "supports a timeout" do

    end
  end
 end
