using JuMP
using Ipopt
using Statistics

"""
    portfolio_mean(weights, returns)
"""

function portfolio_mean(weights, returns)
    r_mean = mean(Array(returns), dims=1)
    return sum(weights .* r_mean)
end


function portfolio_variance(weights, returns)
    cov_matrix = cov(Array(returns))
    return weights' * cov_matrix * weights
end


"""
    optimize_portfolio(returns)
Optimizes the portfolio weights to maximize the expected return subject to a variance constraint.
"""
function optimize_portfolio(returns, var_max)


    portfolio = Model(Ipopt.Optimizer)
    set_silent(portfolio)
    @variable(portfolio, x[1:size(returns)[2]] >= 0)
    @objective(portfolio, Max, portfolio_mean(x, returns))
    @constraint(portfolio, sum(x) == 1)
    @constraint(portfolio, portfolio_variance(x, returns) <= var_max)
    optimize!(portfolio)
    objective_value(portfolio)
    weights_opt = value.(x)
    return weights_opt
end