defmodule Fex.Teams do

  def all_fixtures do
    teams = all
    for home <- teams, away <- teams, home != away do
      {home, away}
    end
  end

  def all do
    team_performance |>
      Dict.keys
  end

  def all_strengths do
    for team <- all(), do: {team, strength(team)}
  end
  
  # We fix the average beta to 0.45 and calculate everything from that.

  # equations:
  # AvgGF =  (alpha * avg(beta) + (xi_1+xi_2)/4) * (1+rho)/2
  # beta = AvgGA / avg_goals_per_team * avg(beta)

  def strength(team) do
    {g, _whl, {gf, ga}, _p} = team_performance()[team]
    avg_gf = gf/g
    avg_ga = ga/g
    alpha = ( (avg_gf / ((1+1.37)/2)) - (0.67+0.47)/4 )  / 0.45
    beta  = avg_ga / avg_goals_per_team() * 0.45
    {alpha, beta}
  end


  defp avg_goals_per_team do
    0.5 * goals_scored() / games_played()
  end

  defp goals_scored() do
    team_performance() |> 
      Enum.reduce(0,
        fn({_team,{_,_,{gf,_},_}}, acc) -> acc+gf end)
  end

  defp games_played() do
    d = team_performance() |> 
      Enum.reduce(0,
        fn({_team,{g,_,{_,_},_}}, acc) -> acc+g end)
    d/2
  end

  defp team_performance do
    %{
    "Chelsea" => {29,{20,7,2},{61,25},67},
    "Manchester City" => {30,{18,7,5},{62,28},61},
    "Arsenal" => {30,{18,6,6},{58,31},60},
    "Manchester United" => {30,{17,8,5},{52,27},59},
    "Liverpool" => {30,{16,6,8},{44,32},54},
    "Southampton" => {30,{16,5,9},{42,21},53},
    "Tottenham Hotspur" => {30,{16,5,9},{50,45},53},
    "Swansea City" => {30,{12,7,11},{34,38},43},
    "West Ham United" => {30,{11,9,10},{40,37},42},
    "Stoke City" => {30,{12,6,12},{34,37},42},
    "Crystal Palace" => {30,{9,9,12},{36,41},36},
    "Newcastle United" => {30,{9,8,13},{33,48},35},
    "Everton" => {30,{8,10,12},{38,42},34},
    "West Bromwich Albion" => {30,{8,9,13},{27,39},33},
    "Hull City" => {30,{6,10,14},{28,40},28},
    "Aston Villa" => {30,{7,7,16},{19,39},28},
    "Sunderland" => {30,{4,14,12},{23,44},26},
    "Burnley" => {30,{5,10,15},{26,49},25},
    "Queens Park Rangers" => {30,{6,4,20},{31,54},22},
    "Leicester City" => {29,{4,7,18},{27,48},19}
  }
  end

end
