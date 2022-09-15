# Demo system

> https://www.youtube.com/watch?v=JvBT4XBdoUE

## Getting started

Requires Erlang and Elixir, as specified in the [.tool-versions](./.tool-versions) file.
You can use [asdf](https://github.com/asdf-vm/asdf) for that.

Building:

```
mix deps.get && mix compile
```

Starting for development with live reload:

```
iex -S mix phx.server
```

Then, you can visit the following links:

  - http://localhost:4000
  - http://localhost:4000/load
  - http://localhost:4000/services

## Demo

Building and starting for production (in the background):

```
mix release --overwrite
NODE_NAME=node1 ./_build/prod/rel/example_system/bin/example_system start
```

Open the remote console:

```
NODE_NAME=node1 ./_build/prod/rel/example_system/bin/example_system remote
```

Hot upgrade with no downtime:

```
mix system.upgrade
```
