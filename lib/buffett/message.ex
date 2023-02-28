defmodule Kafkaesque.Message do
  @moduledoc """
  Kafkaesque.Message provides functions for formatting messages
  to use with Kafka and the like.
  """

  @doc """
  Creates a new kafka request to be produced.
  """
  def to_kafka_request(args) do
    %KafkaEx.Protocol.Produce.Request{
      topic: args[:topic],
      partition: args[:partition],
      required_acks: required_acks(),
      compression: compression(),
      messages: [
        %KafkaEx.Protocol.Produce.Message{
          key: to_global_key(args[:node_name], args[:process_name], args[:key]),
          value: args[:message]
        }
      ]
    }
  end

  defp to_global_key(node_name, process_name, key) do
    "#{node_name}::#{process_name}::#{key}"
  end

  defp required_acks do
    1
  end

  defp compression do
    :gzip
  end
end
