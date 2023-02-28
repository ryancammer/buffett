defmodule Kafkaesque.KafkaDataConsumer do
  @moduledoc """
  Kafkaesque.KafkaDataConsumer provides functionality for
  applying data from Kafka to a Coordinator.
  """

  alias Kafkaesque.Coordinator

  def new do
    fn(data) -> perform(data) end
  end

  @doc """
  Initializes a high order rest function for execution.

  ## Example
  iex> consumer = KafkaDataConsumer.new()
  iex> consumer.(data)
  """
  def perform(data) do
    Enum.each(data, &handle_message/1)
  end

  defp handle_message(message) do
    [_node_name, process_name, key] = String.split(message.key, "::")

    [{pid, _}] = Registry.lookup(Kafkaesque, process_name)

    Coordinator.append(pid, String.to_existing_atom(key), message.value)
  end
end
