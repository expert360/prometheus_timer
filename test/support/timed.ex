defmodule PrometheusTimer.Timed do
  @moduledoc false

  use PrometheusTimer

  @timed :test_function_timer
  def test_one(arg) when is_bitstring(arg) or is_nil(arg) do
    {:ok, arg}
  end

  @timed :test_function_timer
  def test_two do
    raise ArgumentError, "oh no"
  end

  def test_three do
    :ok
  end
end
