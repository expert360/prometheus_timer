defmodule PrometheusTimer.Instrumenter do
  @moduledoc """
  Behaviour to allow mocking of instrumenter in tests
  """
  @callback new(Keyword.t()) :: any()
  @callback observe(Keyword.t(), integer()) :: any()
end
