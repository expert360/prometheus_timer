defmodule PrometheusTimer.Web.Router do
  @moduledoc """
  Mini-plug router to use for testing
  """
  use Plug.Router

  plug PrometheusTimer.Web.Exporter
  plug :match
  plug :dispatch

  match _ do
    conn
    |> send_resp(404, "not found")
    |> halt()
  end
end
