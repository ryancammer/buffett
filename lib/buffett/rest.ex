defmodule Kafkaesque.Rest do
  @moduledoc """
  Kafkaesque.Rest provides a function for retrieving JSON
  from a url, and appending it to a Coordinator.
  """

  alias Kafkaesque.Coordinator
  alias Poison.Parser

  def content_type, do: :"Content-Type"

  def content_types do
    %{
      json: "application/json"
    }
  end

  def methods do
    %{
      get: "get",
      post: "post",
      put: "put",
      patch: "patch",
      delete: "delete"
    }
  end

  @doc """
  Initializes a high order rest function for execution.

  ## Example

  iex> rest = Kafkaesque.Rest.new(key: :product,
  ...> url: "http://product_service/products/1")
  #Function<0.86566734/1 in Kafkaesque.Rest.new/1>
  iex> rest.(coordinator_pid)
  """
  def new(args) do
    fn(pid) -> perform(pid, args) end
  end

  defp perform(pid, args) do
    HTTPotion.start
    method = Keyword.get(args, :method, methods().get)
    headers = get_headers(method, args)
    {:ok, parameters} = get_parameters(method, args)
    opts = Enum.concat([headers: headers], parameters || [])

    response = HTTPotion.request(
      String.to_existing_atom(method),
      args[:url],
      opts
    )

    args[:appender].append(pid, args[:key], Parser.parse!(response.body))
  end

  defp get_headers(method, args) do
    headers = Keyword.get(args, :headers, [])

    if (Keyword.get(headers, content_type()) || method == methods().get) do
      headers
    else
      Keyword.put(headers, content_type(), content_types().json)
    end
  end

  def get_parameters(method, args) do
    body = Keyword.get(args, :body, [])

    case method do
      "get" -> {:ok, body: URI.encode_query(body)}
      verb when verb in ["post", "put", "patch"]
        ->
          {_, body} = Poison.encode(body)
          {:ok, body: body}
      _ -> {:ok, body: nil}
    end
  end
end
