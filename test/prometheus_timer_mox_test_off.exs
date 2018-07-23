defmodule PrometheusTimerMoxTest do
  use ExUnit.Case, async: false

  alias PrometheusTimer.Instrumenter.Mock
  alias PrometheusTimer.Timed

  import Mox

  setup :set_mox_global
  setup :verify_on_exit!

  setup do
    Application.put_env(:prometheus_timer, :instrumenter, Mock)

    :ok
  end

  describe "@timed :bucket" do
    test "can time a public function call" do
      expect(Mock, :observe, fn opts, _ ->
        assert Keyword.fetch!(opts, :name) == :foo
        assert PrometheusTimer.Timed in Keyword.fetch!(opts, :labels)
        assert :test_one in Keyword.fetch!(opts, :labels)

        :ok
      end)

      {:ok, "hello"} = Timed.test_one("hello")
    end

    test "can time a failed function call" do
      expect(Mock, :observe, fn opts, _ ->
        assert Keyword.fetch!(opts, :name) == :bar
        assert PrometheusTimer.Timed in Keyword.fetch!(opts, :labels)
        assert :test_two in Keyword.fetch!(opts, :labels)

        :ok
      end)

      assert_raise ArgumentError, "oh no", fn ->
        Timed.test_two()
      end
    end

    test "that unannotated functions are not given timers" do
      stub(Mock, :observe, fn _, _ ->
        raise RuntimeError, "This should not be called"
      end)

      result = try do
        Timed.test_three()
      catch
        _, _ -> :error
      end

      assert :ok === result
    end
  end
end
