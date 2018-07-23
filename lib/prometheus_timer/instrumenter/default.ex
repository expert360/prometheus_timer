defmodule PrometheusTimer.Instrumenter.Default do
  @moduledoc false
  @behaviour PrometheusTimer.Instrumenter

  require Prometheus.Metric.Histogram

  def new(config) do
    Prometheus.Metric.Histogram.new(config)
  end

  def observe(config, time) do
    Prometheus.Metric.Histogram.observe(config, time)
  end
end
