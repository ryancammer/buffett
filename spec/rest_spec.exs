defmodule Kafkaesque.RestSpec do
  use ESpec

  alias Kafkaesque.{Coordinator, Rest}

  describe "When the Rest function is used" do
    let :endpoint, do: "http://jsonplaceholder.typicode.com/posts"

    let :key, do: :product

    let :pid, do: self()

    let :json_response do
      %HTTPotion.Response{
        body: "{\n  \"args\": {}, \n \"a\": \"1\", \n  \"b\": \"2\"\n}\n"
      }
    end

    let :response, do: :response

    before do
      allow HTTPotion |> to(accept :get, fn(_) -> json_response() end)
      allow Coordinator |> to(accept :append, fn(_, _, _) -> response() end)
    end

    subject do
      Rest.new(
        key: key(),
        url: endpoint(),
        appender: Coordinator
      )
    end

    it "returns the expected response" do
      expect(subject().(pid())).to be(response())
    end
  end

   describe "When the POST Rest function is used" do
      let :endpoint, do: "http://jsonplaceholder.typicode.com/posts"

      let :key, do: :product

      let :pid, do: self()

      let :json_response do
        %HTTPotion.Response{
          body: "{\n  \"args\": {}, \n \"a\": \"1\", \n  \"b\": \"2\"\n}\n"
        }
      end

      let :response, do: :response

      before do
        allow HTTPotion |> to(accept :request, fn(_, _, _) -> json_response() end)
        allow Coordinator |> to(accept :append, fn(_, _, _) -> response() end)
      end

      subject do
        Rest.new(
          key: key(),
          url: endpoint(),
          method: "post",
          body: %{"id" => 1},
          appender: Coordinator
        )
      end

      it "returns the expected response" do
        expect(subject().(pid())).to be(response())
      end
    end
end
