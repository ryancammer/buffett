defmodule Kafkaesque.Consumer do
  @moduledoc """
  Kafkaesque.Consumer provides functionality for consuming data
  from a Kafka topic, and providing that data to a function.
  """

  alias Kafkaesque.Broker

  @doc """
  Initializes a high order rest function for execution.

  ## Example

  iex> action = fn(data) -> Enum.each(data, &IO.inspect/1) end
  iex> rest = Kafkaesque.Consumer.new(action: action)
  #Function<0.86566734/1 in Kafkaesque.Consumer.new/1>
  iex> rest.(0)
  """
  def new(args) do
    fn(offset) -> perform(args, offset) end
  end

  defp perform(args, offset) do
    results = Broker.fetch(args[:topic], offset: offset)
    args[:action].(results)
  end
end
