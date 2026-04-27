using TimeSeries
using Statistics
using LinearAlgebra
using Distributions


"""
    decompose(ta)

Extracts statistical parameters of asset returns needed for Monte Carlo simulation.

# Arguments
- `ta`: TimeArray of asset prices (rows = time steps, columns = assets)

# Returns
- `(mean_r, L)`: vector of mean log return, lower Cholesky factor of the covariance matrix
"""
function decompose(ta::TimeArray)
    data_r = TimeSeries.values(log_returns(ta))
    mean_r = vec(mean(data_r, dims=1))
    L = cholesky(cov(data_r)).L
    return mean_r, L
end


"""
    model(ta, horizon, weights, v)

Simulates portfolio value after `horizon` trading days using a multivariate t-distribution model.

# Arguments
- `ta`: TimeArray of asset prices
- `horizon`: number of trading days to simulate
- `weights`: vector of portfolio weights (one per asset)
- `v`: degrees of freedom for the t-distribution
# Returns
- scalar simulated portfolio value at end of horizon
"""
function model(ta::TimeArray, horizon::Int, weights::Vector, v::Int)
    mean_r, L = decompose(ta)
    P0 = TimeSeries.values(ta)[end, :]
    n = size(ta, 2) 
    rates = Matrix{Float64}(undef, horizon, n)
    for day in 1:horizon
        z = randn(n)
        u = rand(Chisq(v))
        t_sample = z * sqrt(v / u)
        rates[day, :] = L * t_sample .+ mean_r
    end
    r_cum = exp.(vec(sum(rates, dims=1)))
    return sum(weights .* P0 .* r_cum)
end


"""
    run_simulation(iter, ta, horizon, weights, v)

# Arguments
- `iter`: number of simulation iterations
- `ta`: TimeArray of asset prices
- `horizon`: number of trading days to simulate
- `weights`: vector of portfolio weights (one per asset)
- `v`: degrees of freedom for the t-distribution
# Returns
- vector of simulated portfolio values at end of horizon
"""
function run_simulation(iter::Int, ta::TimeArray, horizon::Int, weights::Vector, v::Int)
    return [model(ta, horizon, weights, v) for _ in 1:iter]
end