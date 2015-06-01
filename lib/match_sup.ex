defmodule Fex.Match.Sup do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :no_args, name: __MODULE__)
  end

  def init(:no_args) do
    child = [worker(Fex.Match, [])]
    supervise(child, strategy: :simple_one_for_one)
  end

  def start_match(match_id, home, away, starts_in) do
    Supervisor.start_child(__MODULE__, [match_id, home, away, starts_in])
  end
end
