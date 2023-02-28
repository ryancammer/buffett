defmodule Kafkaesque.Coordinator do
  @moduledoc """
  Kafkaesque.Coordinator provides a GenServer for coordinating
  data, and determining when data is complete.
  """

  use GenServer

  @doc """
  Create a new coordinator function.

  ## Example

  iex> coordinator = Kafkaesque.Coordinator.new(
  ...> initial_action: fn(data) -> data end,
  ...> completion_check: fn(data) -> Enum.all?( [:product, :order] , &(Map.has_key?(data, &1) ) ) end,
  ...> completion_action: fn(data) -> IO.inspect(data) end)
  #PID<0.223.0>
  """
  def new(args) do
    initial_data = Keyword.get(args, :initial_data, %{})

    {:ok, coordinator} = start_link(
      %{
        completion_check: args[:completion_check],
        completion_action: args[:completion_action],
        data: initial_data
      }
    )

    if args[:initial_action], do: initialize(coordinator, args[:initial_action])

    coordinator
  end

  def start_link(state) do
    name = {:via, Registry, {Kafkaesque, unique_name()}}
    GenServer.start_link(__MODULE__, state, name: name)
  end

  @doc """
  Append data to the coordinator, using a key to reference it.

  ## Example

  iex> Coordinator.append(coordinator, :product, %{id: 1})
  %{complete: false}
  iex> Coordinator.append(coordinator, :order, %{id: 1})
  %{complete: true}
  """
  def append(pid, data_key, data) do
    GenServer.call(pid, {:append, data_key, data})
  end

  def handle_cast({:initialize, initial_action}, state) do
    new_data = initial_action.(state[:data])
    {:noreply, Map.merge(state, %{data: new_data})}
  end

  def handle_cast(:stop, state) do
    {:stop, :normal, state}
  end

  def handle_call({:append, data_key, data_to_append}, _from, state) do
    new_state = perform_append(data_key, data_to_append, state)

    complete = perform_completion_check(new_state)

    if complete do
      perform_complete(state[:completion_action], new_state[:data])
    end

    {:reply, %{complete: complete}, new_state}
  end

  defp unique_name, do: UUID.uuid1()

  defp initialize(pid, initial_action) do
    GenServer.cast(pid, {:initialize, initial_action})
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

  defp perform_complete(completion_action, data) do
    completion_action.(data)
  end
end
