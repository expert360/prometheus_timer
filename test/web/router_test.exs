defmodule PrometheusTimer.RouterTest do
  @moduledoc false
  use ExUnit.Case

  describe "PrometheusTimer.Router" do
    test "/metrics will resolve" do
      %{status_code: 200, body: body} =
        HTTPoison.get!("http://localhost:4001/metrics")

      assert body =~ "# HELP test_function_timer Used to test timers in tests"
    end

    test "/404 will 404 as expected" do
      %{status_code: 404, body: body} =
        HTTPoison.get!("http://localhost:4001/404")

      assert body == "not found"
    end
  end
end
