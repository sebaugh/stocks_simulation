module StocksSimulation

include("fetchers/yahoo.jl")
include("returns.jl")
include("portfolio.jl")
include("simulation.jl")

export stocks_data, get_field
export cumulative_returns, log_returns
export portfolio_mean, portfolio_variance, optimize_portfolio
export decompose

end
