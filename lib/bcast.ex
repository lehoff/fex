defmodule Fex.Bcast do

  def publish_match(match_id) do
    Ogma.publish(Fex.NewMatch, {:new_match, match_id})
  end

  def subscribe_matches do
    Ogma.subscribe(Fex.NewMatch)
  end

  def unsubscribe_matches do
    Ogma.unsubscribe(Fex.NewMatch)
  end
  
  def status(match_id, status) do
    match_info = {:fex_match_info, match_id}
    Ogma.publish(match_info, {match_info, status})
  end

  def subscribe_match(match_id) do
    Ogma.subscribe({:fex_match_info, match_id})
  end

  def subscribe_tick() do
    Ogma.subscribe(:fex_tick)
  end

  def unsubscribe_tick() do
    Ogma.unsubscribe(:fex_tick)
  end

  def tick() do
    Ogma.publish(:fex_tick, :tick)
  end

  
end
