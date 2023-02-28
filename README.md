# Buffett

Buffett is a module that provides a Kafka consumer with both
synchronous and asynchronous methods of communicating with
other services using REST or Kafka.

This library was initially something that I wrote and open
sourced at another company, but was never used. I'm now
open sourcing it here for anyone who might find it useful.

## Requirements

Buffett requires the following open source projects:

* [Elixir](http://elixir-lang.org/) - The joy of Ruby, power of Erlang.
* [Kafka](https://kafka.apache.org/) - A distributed streaming platform.

## Usage

For development, add the following entries to your hosts file:
```bash
$ echo "127.0.0.1 kafka" >> /etc/hosts
```

Incorporate Buffett into your project by adding the following to mix.exs:

```elixir
defp deps do
  [
    ...,
    {:buffett, git: "https://github.com/ryancammer/buffett.git"},
    ...
  ]
end
```

To use Buffett synchronously:

```elixir

alias Buffett.{
  KeyCompletionCheck,
  Rest,
  SynchronousGatherer
}

actions = [
  Rest.new(
    key: :product,
    url: "https://product_service/products/1",
    appender: SynchronousGatherer
  ),
  Rest.new(
    key: :order,
    url: "https://order_service/orders/1",
    appender: SynchronousGatherer
  )
]

completion_check = KeyCompletionCheck.new(completion_keys: [:product, :order])

result = SynchronousGatherer.perform(
  completion_check: completion_check,
  actions: actions,
)

```

For more examples, check the specs in the integration directory.
