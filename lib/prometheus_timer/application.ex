defmodule PrometheusTimer.Application do
  @moduledoc false

  alias Plug.Adapters.Cowboy
  alias PrometheusTimer.Web.{Exporter, Router}

  def start(_, _) do
    import Supervisor.Spec

    children = [
      supervisor(PrometheusTimer, [])
    ] ++ mix_env_children(Mix.env)

    Supervisor.start_link(children, strategy: :one_for_one)
  end

  defp mix_env_children(env) when env in [:dev, :test] do
    Exporter.setup()

    [
      Cowboy.child_spec(
        scheme: url_scheme(),
        plug: Router,
        options: [port: port()]
      )
    ]
  end
  defp mix_env_children(_), do: []

  defp port,
    do: Application.get_env(:prometheus_timer, :port, 4000)
  defp url_scheme,
    do: Application.get_env(:prometheus_timer, :url_scheme, :http)
end
