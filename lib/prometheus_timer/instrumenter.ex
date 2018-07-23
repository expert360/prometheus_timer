defmodule PrometheusTimer.Instrumenter do
  @moduledoc false
  @callback new(Keyword.t()) :: any()
  @callback observe(Keyword.t(), integer()) :: any()
end
