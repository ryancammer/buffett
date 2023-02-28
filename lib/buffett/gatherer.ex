defmodule Kafkaesque.Gatherer do
  @moduledoc """
  Kafkaesque.Gatherer provides an interface for gathering data.
  """

  alias Kafkaesque.Coordinator

  @doc """
  Performs data gathering

  ## Example

  iex> Gatherer.perform(
  ...> completion_check: fn(data) -> Enum.all?([:p, :o], &(Map.has_key?(data, &1) ) ) end,
  ...> actions: [Rest.new(key: :product, url: "http://product_services/p/1")],
  ...> completion_action: fn(data) -> IO.puts data end)
  """
  def perform(args) do
    coordinator = Coordinator.new(
      initial_action: fn(data) -> data end,
      completion_check: args[:completion_check],
      completion_action: args[:completion_action]
    )

    Enum.each(args[:actions], fn(action) -> action.(coordinator) end)

    coordinator
  end
end
