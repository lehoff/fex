defmodule Fex.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :no_args, name: __MODULE__)
  end

  def init(:no_args) do
    children = [supervisor(Fex.Match.Sup, []),
                worker(Fex.Match.Id, []),
                worker(Fex.Ticks, [])]
    supervise(children, strategy: :one_for_one)
  end
  
end
