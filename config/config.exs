use Mix.Config

env_config = Path.expand("kafka_#{Mix.env}.exs", __DIR__)

if File.exists?(env_config), do: import_config(env_config)
