defmodule Kafkaesque.Broker do
  @moduledoc """
  Kafkaesque.Broker provides functions for producing messages to
  and consuming messages from topics.
  """

  @doc """
  Produce a message to a topic.

  ## Example
  iex> Kafkaesque.Broker.produce("Some Message", "Some Topic")
  :ok
  """
  def produce(topic, message) do
    KafkaEx.produce(topic, partition(), message)
  end

  @doc """
  Produce a message to a topic using a KafkaEx.Protocol.Produce.Request.

  ## Example
  iex> Kafkaesque.Broker.produce(request)
  :ok
  """
  def produce(request) do
    KafkaEx.produce(request)
  end

  @doc """
  Fetch messages from a topic.

  ## Example

  iex> Kafkaesque.Broker.fetch("Some Topic")
  ["Some Message 1", "Some Message 2"]
  """
  def fetch(topic, opts \\ []) do
    supplied_offset = Keyword.get(opts, :offset, latest_offset(topic))
    [response] = KafkaEx.fetch(topic, partition(), offset: supplied_offset)
    [partitions] = response.partitions
    partitions.message_set
  end

  @doc """
  Get the latest offset from a topic. It returns 0 if there
  is no topic.

  ## Example

  iex> Kafkaesque.Broker.latest_offset("Some Topic")
  2
  """
  def latest_offset(topic) do
     case KafkaEx.latest_offset(topic, partition()) do
       [offset_data] ->
         [partition_offset] = offset_data.partition_offsets
         [offset] = partition_offset[:offset]
         offset
       _ ->
         0
     end
  end

  defp partition do
    0
  end
end
