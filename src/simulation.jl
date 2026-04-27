using TimeSeries
using Statistics
using LinearAlgebra


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
    model(ta, horizon, weights)

Simulates portfolio value after `horizon` trading days using a multivariate normal model.

# Arguments
- `ta`: TimeArray of asset prices
- `horizon`: number of trading days to simulate
- `weights`: vector of portfolio weights (one per asset)

# Returns
- scalar simulated portfolio value at end of horizon
"""
function model(ta::TimeArray, horizon::Int, weights::Vector)
    mean_r, L = decompose(ta)
    P0 = TimeSeries.values(ta)[end, :]
    n = size(ta, 2)
    rates = Matrix{Float64}(undef, horizon, n)
    for day in 1:horizon
        rates[day, :] = L * randn(n) .+ mean_r
    end
    r_cum = exp.(vec(sum(rates, dims=1)))
    return sum(weights .* P0 .* r_cum)
end


"""
    run_simulation(iter, ta, horizon, weights)

# Arguments
- `iter`: number of simulation iterations
- `ta`: TimeArray of asset prices
- `horizon`: number of trading days to simulate
- `weights`: vector of portfolio weights (one per asset)

# Returns
- vector of simulated portfolio values at end of horizon
"""
function run_simulation(iter::Int, ta::TimeArray, horizon::Int, weights::Vector)
    return [model(ta, horizon, weights) for _ in 1:iter]
end