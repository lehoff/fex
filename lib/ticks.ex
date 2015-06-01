defmodule Fex.Ticks do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, :no_args, [name: __MODULE__])
  end

  def init(:no_args) do
    interval = 1000
    tref = new_interval_timer(interval)
    {:ok, %{tref: tref, interval: interval}}
  end

  def run(), do: GenServer.cast(__MODULE__, :run)

  def stop(), do: GenServer.cast(__MODULE__, :stop)

  def set_interval(t) when is_integer(t) do
    GenServer.cast(__MODULE__, {:set_interval, t})
  end
  
  def interval(), do: GenServer.call(__MODULE__, :interval)


  def handle_cast(:run, s) do
    cancel_timer(s.tref)
    tref = new_interval_timer(s.interval)
    {:noreply, %{s | tref: tref}}
  end

  def handle_cast(:stop, s) do
    cancel_timer(s.tref)
    {:noreply, %{s | tref: nil}}
  end

  def handle_cast({:set_interval, t}, s) do
    cancel_timer(s.tref)
    tref = new_interval_timer(t)
    {:noreply, %{s | tref: tref, interval: t}}
  end

  def handle_call(:interval, _from, s) do
    reply = s.interval
    {:reply, reply, s}
  end
  
################################################################################
## Internal functions
  defp new_interval_timer(t) do
    {:ok, tref} = :timer.apply_interval(t, Fex.Bcast, :tick, [])
    tref
  end

  defp cancel_timer(tref) do
    unless is_nil(tref), do: :timer.cancel(tref)
  end
end
