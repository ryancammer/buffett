defmodule Kafkaesque.KeyCompletionCheck do
  @moduledoc """
  Kafkaesque.KeyCompletionCheck provides a predicate function that determines
  when completion criteria is achieved.
  """

  @doc """
  Create a new completion function.

  ## Example

  iex> comp = KeyCompletionCheck.init(completion_keys: [:product, :order])
  #Function<1.112397235/1 in Kafkaesque.Completion.new/1>
  iex> comp.(%{product: true})
  false
  iex> comp.(%{product: true, order: true})
  true
  """
  def new(args) do
    fn(data) -> complete?(data, args[:completion_keys]) end
  end

  defp complete?(data, completion_keys) do
    Enum.all?(completion_keys, &(Map.has_key?(data, &1)))
  end
end
