defmodule Fex.App do
  use Application

  def start(_type, _args) do
    Fex.Supervisor.start_link
  end
end
