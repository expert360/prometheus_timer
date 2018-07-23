
use Mix.Config

config :prometheus,
  collectors: [
    :prometheus_histogram
  ]

config :prometheus_timer,
  instrumenter: PrometheusTimer.Instrumenter.Default,
  timers: []

import_config "#{Mix.env}.exs"
