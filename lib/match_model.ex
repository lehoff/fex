defmodule Fex.MatchModel do

  defmodule Model do
    defstruct lambda: 1.0,
    mu: 1.0,
    stoppage1: 0,
    stoppage2: 0,
    status: {:first_half, 0, {0,0}}
  end

  @home_advantage 1.37
  @type minute :: non_neg_integer
  @type score  :: {non_neg_integer, non_neg_integer}
  @type status :: {:first_half, minute, score}
  | {:halftime, score}
  | {:second_half, minute, score}
  | {:finished, score}
  
  @opaque t :: %Model{lambda: float,
                      mu: float,
                      stoppage1: 0..3,
                      stoppage2: 0..6,
                      status: status}

  @spec new(lambda :: float, mu :: float) :: t
  def new(lambda, mu) do
    %Model{lambda: lambda * @home_advantage,
           mu: mu,
           stoppage1: stoppage(1),
           stoppage2: stoppage(2)}
  end

  def status(m), do: m.status

  @spec tick(t) :: t  
  def tick(%Model{status: {:finished,_}}=m), do: m

  def tick(%Model{status: {:halftime, score}}=m) do
    %{m | status: {:second_half, 45, score} }
  end

  def tick(%Model{status: {:first_half, t, score}, stoppage1: s1}=m) when t>=45+s1 do
    %{m | status: {:halftime, score}}
  end

  def tick(%Model{status: {:second_half, t, score}, stoppage2: s2}=m) when t>=90+s2 do
    %{m | status: {:finished, score}}
  end

  def tick(%Model{status: {half, t, {gh, ga}=score}}=m) do
    %{m | status: {half, t+1, {gh + goal(lambda(m.lambda, score, t)),
                                ga + goal(mu(m.mu, score, t))}}}
  end

  def lambda(lambda, score, t) do
    lambda * lambda_xy(score) + xi_1(t)
  end

  def mu(mu, score, t) do
    mu * mu_xy(score) + xi_2(t)
  end

  def lambda_xy({n,n}), do: 1.00
  def lambda_xy({1,0}), do: 0.86
  def lambda_xy({0,1}), do: 1.10
  def lambda_xy({gh, ga}) when gh>ga and gh>1, do: 1.01
  def lambda_xy(_), do: 1.13

  def mu_xy({n,n}), do: 1.00
  def mu_xy({1,0}), do: 1.33
  def mu_xy({0,1}), do: 1.07
  def mu_xy({gh, ga}) when gh>ga and gh>1, do: 1.53
  def mu_xy(_), do: 1.16

  def xi_1(t), do: 0.67/90 * t/90

  def xi_2(t), do: 0.47/90 * t/90

  def goal(lambda) do
    case rand() < lambda do
      true -> 1
      false -> 0
    end
  end

  defp rand() do
    :random.uniform
  end
  
  @spec sim_match(t) :: score
  def sim_match(%Model{status: {:finished, score}}) do
    score
  end

  def sim_match(m) do
    sim_match(tick(m))
  end
  
  @spec stoppage(integer) :: 0..6
  defp stoppage(1) do
    :crypto.rand_uniform(0,3)
  end

  defp stoppage(2) do
    :crypto.rand_uniform(1,3) + :crypto.rand_uniform(0,5)
  end

  def test(1) do
    new(2.27*0.28/90, 2.55*0.36/90)
  end

   
end
