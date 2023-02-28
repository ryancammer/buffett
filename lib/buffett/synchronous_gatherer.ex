defmodule Kafkaesque.SynchronousGatherer do
  @moduledoc """
  Kafkaesque.SynchronousGatherer provides a mechanism for
  blocking a process until all of the data is present.
  It then returns a value.
  """

  use GenServer

  @doc """
  Perform the blocking call.

  ## Example

  iex> result = Kafkaesque.SynchronousGatherer.perform(
  ...> initial_actions: fn(data) -> data end,
  ...> completion_check: fn(data) -> Enum.all?( [:product, :order] , &(Map.has_key?(data, &1) ) ) end,
  ...> )
  """
  def perform(args) do
    initial_data = Keyword.get(args, :initial_data, %{})

    {:ok, queue_pid} = BlockingQueue.start_link(1)

    {:ok, gatherer} = start_link(
      %{
        completion_check: args[:completion_check],
        data: initial_data,
        queue: queue_pid
      }
    )

    initialize(gatherer, args[:initial_actions])

    BlockingQueue.pop(queue_pid)
  end

  @doc """
  Append data to the gatherer, using a key to reference the data.

  ## Example

  iex> SynchronousGatherer.append(gatherer, :product, %{id: 1})
  %{complete: false}
  iex> SynchronousGatherer.append(gatherer, :order, %{id: 1})
  %{complete: true}
  """
  def append(pid, data_key, data) do
    GenServer.call(pid, {:append, data_key, data})
  end

  def start_link(state) do
    name = {:via, Registry, {Kafkaesque, unique_name()}}
    GenServer.start_link(__MODULE__, state, name: name)
  end

  def handle_cast(:stop, state) do
    {:stop, :normal, state}
  end

  def handle_call({:append, data_key, data_to_append}, _from, state) do
    new_state = perform_append(data_key, data_to_append, state)

    complete = perform_completion_check(new_state)

    if complete do
      perform_complete(new_state[:queue], new_state[:data])
    end

    {:reply, %{complete: complete}, new_state}
  end

  defp initialize(_, nil), do: nil
  defp initialize(pid, initial_actions) do
    Enum.each(initial_actions, fn(action) -> action.(pid) end)
  end

  defp perform_completion_check(state) do
    completion_check = state[:completion_check]
    completion_check.(state[:data])
  end

  defp perform_append(data_key, data_to_append, state) do
    data = state[:data]
    new_data = Map.merge(data, %{data_key => data_to_append})
    Map.merge(state, %{data: new_data})
  end

  defp perform_complete(queue_pid, data) do
    BlockingQueue.push(queue_pid, data)
  end

  defp unique_name, do: UUID.uuid1()
end
