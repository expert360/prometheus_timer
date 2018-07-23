# PrometheusTimer

A [Prometheus](https://github.com/deadtrickster/prometheus.ex) helper which
uses "annotations" to apply timers to functions. It works by overriding the
original function with an implementation which includes code to instrument
the call.

Inspired by [Elixometer](https://github.com/pinterest/elixometer).

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `prometheus_timer` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:prometheus_timer, "~> 0.1.0"}
  ]
end
```

## Getting started

The first step is to provide configuration for your timers. This is done using
configuration, with each bucket configuration being provided in the format
expected when calling `&Prometheus.Metric.Histogram.new/1`:

```
use Mix.Config

config :prometheus_timer, timers: [
  [
    name: :foo,
    buckets: [100, 300, 500, 750, 1000],
    help: "Time to foo"
  ],
  [
    name: :bar,
    buckets: [100, 300, 500, 750, 1000],
    help: "Time to bar"
  ]
]
```
**N.B.: if you add labels they will be ignored**

Once installed, any module can be enabled for timers by `use`-ing the module
`PromethusTimer`. Then functions can have timers added to them by using the
annotation `@timed`, followed by the name of the timer:

```
defmodule Timed do
  use PrometheusTimer

  @timed :foo
  def save_foo(foo) do
    {:ok, foo} = FooService.do_hard_work_with_foo(foo)
  end
end
```

After that, any calls made to `&Timed.foo/1` will be wrapped in a timer, which
will push an observation to `:foo`. The labels which will be associated with
the metric will be the module and function name, respectively.

## Contributing

Contributions are welcome. The project is Dockerised and controlled using GNU
Make commands. To get started, run `make init` from the root directory, and you
will build and start the container, then be presented with an interactive
shell.

When operating in development and test modes, a small Plug router will be spun
up to run an exporter. In dev it will be available on port 4000, in test 4001.

## License

```
This work is free. You can redistribute it and/or modify it under the
terms of the Apache License. See the LICENSE file for more details.
```
