defmodule Kafkaesque.RestSynchronousGathererSpec do
  use ESpec

  alias Kafkaesque.{
    KeyCompletionCheck,
    Rest,
    SynchronousGatherer
  }

  describe "A successful round trip" do
    let :actions do
      [
        Rest.new(
          key: :product,
          url: "http://jsonplaceholder.typicode.com/posts/1",
          appender: SynchronousGatherer
        ),
        Rest.new(
          key: :order,
          url: "http://jsonplaceholder.typicode.com/posts/1",
          appender: SynchronousGatherer
        )
      ]
    end

    let :post_actions do
      [
        Rest.new(
          key: :product,
          method: "post",
          body: %{
            "title" => "foo",
            "body" => "bar",
            "userId" => 1
          },
          url: "http://jsonplaceholder.typicode.com/posts",
          appender: SynchronousGatherer
        ),
        Rest.new(
          key: :order,
          method: "post",
          body: %{
            "title" => "stuff",
            "body" => "also stuff",
            "userId" => 2
          },
          url: "http://jsonplaceholder.typicode.com/posts",
          appender: SynchronousGatherer
        )
      ]
    end

    it "makes a round trip call" do
      Registry.start_link(:unique, Kafkaesque)

      result = SynchronousGatherer.perform(
        completion_check: KeyCompletionCheck.new(completion_keys: [:product, :order]),
        initial_actions: actions()
      )

      expect(Map.keys(result)).to be([:order, :product])
    end

    it "makes a round trip post" do
      Registry.start_link(:unique, Kafkaesque)

      result = SynchronousGatherer.perform(
        completion_check: KeyCompletionCheck.new(completion_keys: [:product, :order]),
        initial_actions: post_actions()
      )

      expect(Map.keys(result)).to be([:order, :product])
    end
  end
end