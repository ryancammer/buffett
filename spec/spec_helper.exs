ESpec.configure fn(config) ->
  config.before fn(_tags) ->
    Registry.start_link(:unique, Kafkaesque)
  end

  config.finally fn(_shared) ->
    :ok
  end
end
