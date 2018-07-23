defmodule PrometheusTimer.RouterTest do
  @moduledoc false
  use ExUnit.Case

  setup do
    {:ok,
      url_scheme: Application.get_env(:prometheus_timer, :url_schema, :http),
      port: Application.get_env(:prometheus_timer, :port, 4001)}
  end

  describe "PrometheusTimer.Router" do
    test "/metrics will resolve", %{url_scheme: url_scheme, port: port} do
      %{status_code: 200, body: body} =
        HTTPoison.get!("#{url_scheme}://localhost:#{port}/metrics")

      assert body =~ "# HELP test_function_timer Used to test timers in tests"
    end

    test "/404 will 404 as expected", %{url_scheme: url_scheme, port: port} do
      %{status_code: 404, body: body} =
        HTTPoison.get!("#{url_scheme}://localhost:#{port}/404")

      assert body == "not found"
    end
  end
end
