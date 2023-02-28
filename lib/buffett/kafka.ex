defmodule Kafkaesque.Kafka do
  @moduledoc """
  Kafkaesque.Kafka provides functionality for producing data
  to a Kafka topic.
  """

  alias Kafkaesque.{Broker, Message}

  @doc """
  Initializes a high order rest function for execution.

  ## Example
  iex> kafka = Kafka.new(
  ...> key: "order",
  ...> message: "o hai",
  ...> partition: 0,
  ...> topic: "some_topic")
  iex> kafka.(coordinator)
  """
  def new(args) do
    fn(pid) -> perform(pid, args) end
  end

  defp perform(pid, args) do
    Broker.produce(
      request(merged_args(pid, args))
    )
  end

  defp merged_args(pid, args) do
    Keyword.merge(
      args,
      [process_name: process_name(pid), node_name: node_name()]
    )
  end

  defp node_name do
    {:ok, name} = :inet.gethostname
    name
  end

  defp process_name(pid) do
    [name] = Registry.keys(Kafkaesque, pid)
    name
  end

  defp request(args) do
    Message.to_kafka_request(args)
  end
end
