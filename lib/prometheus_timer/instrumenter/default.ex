defmodule PrometheusTimer.Instrumenter.Default do
  @moduledoc false
  @behaviour PrometheusTimer.Instrumenter

  alias Prometheus.Metric.Histogram
  require Histogram

  def new(config) do
    Histogram.new(config)
  end

  def observe(config, time) do
    Histogram.observe(config, time)
  end
end
