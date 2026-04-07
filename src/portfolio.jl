using JuMP
using Ipopt
using Statistics
using TimeSeries

"""
    portfolio_mean(weights, returns)

Computes the expected return of a portfolio.

# Arguments
- `weights`: vector of portfolio weights
- `returns`: TimeArray of asset returns (rows = time steps, columns = assets)

# Returns
- scalar expected portfolio return
"""
function portfolio_mean(weights, returns::TimeArray)
    r_mean = mean(TimeSeries.values(returns), dims=1)
    return sum(weights .* r_mean)
end


"""
    portfolio_variance(weights, returns)

Computes the variance of a portfolio using the covariance matrix of asset returns.

# Arguments
- `weights`: vector of portfolio weights
- `returns`: TimeArray of asset returns (rows = time steps, columns = assets)

# Returns
- scalar portfolio variance
"""
function portfolio_variance(weights, returns::TimeArray)
    cov_matrix = cov(TimeSeries.values(returns))
    return weights' * cov_matrix * weights
end


"""
    optimize_portfolio(returns, var_max)

Optimizes portfolio weights to maximise expected return subject to a variance constraint.

# Arguments
- `returns`: TimeArray of asset returns (rows = time steps, columns = assets)
- `var_max`: maximum allowed portfolio variance

# Returns
- vector of optimal portfolio weights
"""
function optimize_portfolio(returns::TimeArray, var_max)
    portfolio = Model(Ipopt.Optimizer)
    set_silent(portfolio)
    @variable(portfolio, x[1:size(returns)[2]] >= 0)
    @objective(portfolio, Max, portfolio_mean(x, returns))
    @constraint(portfolio, sum(x) == 1)
    @constraint(portfolio, portfolio_variance(x, returns) <= var_max)
    optimize!(portfolio)
    weights_opt = value.(x)
    return weights_opt
end