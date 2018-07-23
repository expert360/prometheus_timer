defmodule PrometheusTimerPlugTest do
  use ExUnit.Case, async: false

  alias PrometheusTimer.Timed

  setup do
    scheme = Application.get_env(:prometheus_timer, :url_schema, :http)
    port   = Application.get_env(:prometheus_timer, :port, 4001)

    {:ok, url: "#{scheme}://localhost:#{port}/metrics"}
  end

  describe "@timed annotated function" do
    test "can observe a timed event", %{url: url} do
      {:ok, "hello"} = Timed.test_one("hello")

      %{status_code: 200, body: body} = HTTPoison.get!(url)

      assert body =~
        "test_function_timer_count{" <>
        "module=\"Elixir.PrometheusTimer.Timed\"," <>
        "function=\"test_one\"} 1"
    end

    test "can observe a failed event", %{url: url} do
      assert_raise ArgumentError, "oh no", fn ->
        Timed.test_two()
      end

      %{status_code: 200, body: body} = HTTPoison.get!(url)

      assert body =~
        "test_function_timer_count{" <>
        "module=\"Elixir.PrometheusTimer.Timed\"," <>
        "function=\"test_two\"} 1"
    end

    test "that unannotated functions are not given timers", %{url: url} do
      Timed.test_three()

      %{status_code: 200, body: body} = HTTPoison.get!(url)

      assert String.contains?(
        body,
        "test_function_timer_bucket{module=\"Elixir.Timed\",function=\"test_three\"} 0"
      ) == false
    end
  end
end
