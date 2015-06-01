defmodule Fex.Match do
  alias Fex.MatchModel

  @behaviour :gen_fsm

  @type status :: {:stats_in, MatchModel.minute} |
  {:halftime, MatchModel.minute, MatchModel.score} |
  MatchModel.status

  @type match_id  :: non_neg_integer

  defmodule State do
    defstruct match_id: 0,
    home_name: "",
    away_name: "",
    match: :undefined
  end

  def start_link(match_id, home, away, starts_in) do
    :gen_fsm.start_link(process_name(match_id), __MODULE__,
    [match_id, home, away, starts_in], [])
  end

  def status(match_id) do
    process_name(match_id) |>
      :gen_fsm.sync_send_all_state_event(:status)
  end

  def teams(match_id) do
    process_name(match_id) |>
      :gen_fsm.sync_send_all_state_event(:teams)
  end

  def tick(match_id) do
    process_name(match_id) |>
      :gen_fsm.send_event(:tick)
  end

  def init([match_id, {home_name, {alpha_h, beta_h}}, {away_name, {alpha_a, beta_a}}, starts_in]) do
    lambda = alpha_h * beta_a / 90
    mu     = alpha_a * beta_h / 90
    match  = MatchModel.new(lambda, mu)
    Fex.Bcast.subscribe_tick
    broadcast_status(match_id, {:starts_in, starts_in})
    {:ok, :starts_in, {starts_in, %State{match_id: match_id,
                                         home_name: home_name,
                                         away_name: away_name,
                                         match: match}}} 
  end

  def starts_in(:tick, {0, s}) do
    status = MatchModel.status(s.match)
    broadcast_status(s.match_id, status)
    {:next_state, :first_half, s}
  end

  def starts_in(:tick, {n, s}) do
    broadcast_status(s.match_id, {:starts_in, n-1})
    {:next_state, :starts_in, {n-1, s}}
  end

  def first_half(:tick, s) do
    m = MatchModel.tick(s.match)
    s = %{s | match: m}
    case MatchModel.status(m) do
      {:halftime, score} ->
        status = {:halftime, 15, score}
        broadcast_status(s.match_id, status)
        {:next_state, :halftime, {15, s}}
      status ->
        broadcast_status(s.match_id, status)
        {:next_state, :first_half, s}
    end
  end

  def halftime(:tick, {0, s}) do
    m = MatchModel.tick(s.match)
    s = %{s | match: m}
    broadcast_status(s.match_id, MatchModel.status(m))
    {:next_state, :second_half, s}
  end

  def halftime(:tick, {n, s}) do
    {:halftime, score} = MatchModel.status(s.match)
    status = {:halftime, n-1, score}
    broadcast_status(s.match_id, status)
    {:next_state, :halftime, {n-1, s}}
  end

  def second_half(:tick, s) do
    m = MatchModel.tick(s.match)
    s = %{s | match: m}
    case MatchModel.status(m) do
      {:finished, _score} = status ->
        Fex.Bcast.unsubscribe_tick
        broadcast_status(s.match_id, status)
        {:next_state, :finished, s}
      status ->
        broadcast_status(s.match_id, status)
        {:next_state, :second_half, s}
    end
  end

  def finished(:tick, s) do
    {:next_state, :finished, s}
  end

  def handle_sync_event(:status, _from, :starts_in, {n, s}) do
    reply = {:starts_in, n}
    {:reply, reply, :starts_in, {n, s}}
  end

  def handle_sync_event(:status, _from, :halftime, {n, s}) do
    {:halftime, score} = MatchModel.status(s.match)
    reply = {:halftime, n, score}
    {:reply, reply, :halftime, {n, s}}
  end

  def handle_sync_event(:status, _from, state_name, s) do
    reply = MatchModel.status(s.match)
    {:reply, reply, state_name, s}
  end

  def handle_sync_event(:teams, _from, state_name, {n,s}) do
    reply = {s.home_name, s.away_name}
    {:reply, reply, state_name, {n, s}}
  end

  def handle_sync_event(:teams, _from, state_name, s) do
    reply = {s.home_name, s.away_name}
    {:reply, reply, state_name, s}
  end

  def handle_event(_event, _state_name, s) do
    {:stop, :not_implemented, s}
  end

  def handle_info(:tick, state_name, {n, s}) do
    tick(s.match_id)
    {:next_state, state_name, {n, s}}
  end

  def handle_info(:tick, state_name, s) do
    tick(s.match_id)
    {:next_state, state_name, s}
  end

  def terminate(_reason, _state_name, _s) do
    :ok
  end

  def code_change(_old_vsn, state_name, s, _extra) do
    {:ok, state_name, s}
  end

  defp broadcast_status(match_id, status) do
    Fex.Bcast.status(match_id, status)
  end

  defp process_name(match_id) do
    {:global, {:fex_match, match_id}}
  end
  
  def test(1) do
    start_link(1, {"ManU", {2.4,0.3}},
               {"ManC", {2.7,0.45}},
               10)
  end


  
end
