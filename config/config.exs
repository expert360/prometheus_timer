
use Mix.Config

config :prometheus,
  collectors: [
    :prometheus_histogram
  ]

config :prometheus_timer,
  instrumenter: PrometheusTimer.Instrumenter.Default,
  timers: [],
  purge_from: [:dev]

import_config "#{Mix.env}.exs"
