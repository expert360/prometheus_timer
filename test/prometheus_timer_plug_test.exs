defmodule PrometheusTimerPlugTest do
  use ExUnit.Case, async: false

  alias PrometheusTimer.Timed

  setup do
    Application.ensure_all_started(:prometheus_timer)

    :ok
  end

  describe "@timed annotated function" do
    test "can observe a timed event" do
      {:ok, "hello"} = Timed.test_one("hello")

      %{status_code: 200, body: body} = HTTPoison.get!("http://localhost:4001/metrics")

      assert body =~ "test_function_timer_bucket{module=\"Elixir.PrometheusTimer.Timed\",function=\"test_one\""
    end

    test "can observe a failed event" do
      assert_raise ArgumentError, "oh no", fn ->
        Timed.test_two()
      end

      %{status_code: 200, body: body} = HTTPoison.get!("http://localhost:4001/metrics")

      assert body =~ "test_function_timer_bucket{module=\"Elixir.PrometheusTimer.Timed\",function=\"test_two\""
    end

    test "that unannotated functions are not given timers" do
      Timed.test_three()

      %{status_code: 200, body: body} = HTTPoison.get!("http://localhost:4001/metrics")

      assert String.contains?(
        body,
        "test_function_timer_bucket{module=\"Elixir.Timed\",function=\"test_three\""
      ) == false
    end
  end
end
