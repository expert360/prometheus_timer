defmodule PrometheusTimer do
  @moduledoc """
  See README.md for details.
  """

  @template ~s"""
  <%= type %> <%= name %>(<%= arg_str %>) <%= guard_str %> do
    start = :os.system_time()
    result = try do
      <%= internal_name %>(<%= arg_str %>)
    after
      total = :os.system_time() - start

      instrumenter().observe([
        name: :<%= timer %>,
        labels: [<%= module %>, :<%= name %>]
      ], total)
    end

    result
  end

  defp <%= internal_name %>(<%= arg_str %>) <%= guard_str %> do
    <%= body %>
  end
  """

  # GenServer to handle setting up the instrumenter(s)
  use GenServer

  require Logger

  def start_link do
    GenServer.start_link(__MODULE__, [])
  end

  def init(_) do
    timers       = timers()
    instrumenter = instrumenter()

    Enum.each(timers, fn timer ->
      Logger.debug fn ->
        "Starting timer #{inspect timer}"
      end

      timer
      |> Keyword.put(:labels, [:module, :function])
      |> instrumenter.new()
    end)

    {:ok, timers}
  end

  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__)

      Module.register_attribute(__MODULE__, :functions, accumulate: true)

      @before_compile unquote(__MODULE__)
      @on_definition unquote(__MODULE__)

      defp instrumenter, do: Application.fetch_env!(:prometheus_timer, :instrumenter)
    end
  end

  def __on_definition__(%{module: mod}, kind, fun, args, guards, body) do
    timer = Module.get_attribute(mod, :timed, nil)

    if timer != nil do
      Module.put_attribute(mod, :functions, {timer, kind, fun, args, guards, body})
      Module.put_attribute(mod, :timed, nil)
    end
  end

  defmacro __before_compile__(%{module: mod}) do
    functions =
      mod
      |> Module.get_attribute(:functions)
      |> Enum.map(fn fun ->
        compile_fun(mod, fun)
      end)

    overridable =
      mod
      |> Module.get_attribute(:functions)
      |> Enum.map(fn {_, _, fun, args, _, _} ->
        {fun, length(args)}
      end)

    quote do
      defoverridable unquote(overridable)
      unquote_splicing(functions)
    end
  end

  defp compile_fun(mod, {timer, type, name, args, guards, do: body}) do
    internal_name =
      name
      |> Atom.to_string()
      |> String.replace_prefix("", "__")
      |> String.replace_suffix("", "__")
      |> String.to_atom()

    arg_str =
      args
      |> Enum.map(fn {a, _, _} -> a end)
      |> Enum.join(",")

    guard_str =
      guards
      |> Enum.map(&Macro.to_string/1)
      |> Enum.join(" ")
      |> case do
        "" -> ""
        str -> "when #{str}"
      end

    bindings = [
      type: type,
      name: name,
      arg_str: arg_str,
      guard_str: guard_str,
      internal_name: internal_name,
      timer: timer,
      module: mod,
      body: Macro.to_string(body)
    ]

    functions =
      @template
      |> EEx.eval_string(bindings)
      |> Code.string_to_quoted!()

    quote do
      unquote(functions)
    end
  end

  defp instrumenter, do: Application.fetch_env!(:prometheus_timer, :instrumenter)
  defp timers, do: Application.fetch_env!(:prometheus_timer, :timers)
end
