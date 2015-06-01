defmodule Fex do
  alias Fex.Bcast

  def subscribe_match(match_id) do
    Bcast.subscribe_match(match_id)
  end

  def match_info(match_id) do
    {Fex.Match.teams(match_id), Fex.Match.status(match_id)}
  end

  def subscribe_matches, do: Fex.Bcast.subscribe_matches
  def unsubscribe_matches, do: Fex.Bcast.unsubscribe_matches

  def new_match() do
    match_id = Fex.Match.Id.new
    {home, away} = random_match
    home_strength = Fex.Teams.strength(home)
    away_strength = Fex.Teams.strength(away)
    starts_in = :random.uniform(51) + 9
    Fex.Match.Sup.start_match(match_id,
                              {home, home_strength},
                              {away, away_strength},
                              starts_in)
    Fex.Bcast.publish_match(match_id)
    match_id
  end

  def random_match do
    fixtures = Fex.Teams.all_fixtures
    index = :random.uniform(length(fixtures))-1
    Enum.at(fixtures, index)
  end

  def start_ticks, do: Fex.Ticks.run
  def stop_ticks, do: Fex.Ticks.stop
  def tick_interval, do: Fex.Ticks.interval
  def set_tick_interval(t), do: Fex.Ticks.set_interval(t)
    
end
