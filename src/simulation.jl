using TimeSeries
using Statistics
using LinearAlgebra


"""
    decompose(ta)

Extracts statistical parameters of asset returns needed for Monte Carlo simulation.

# Arguments
- `ta`: TimeArray of asset prices (rows = time steps, columns = assets)

# Returns
- `(mean_r, std_r, L)`: scalar mean log return, scalar std of log returns,
  lower Cholesky factor of the correlation matrix
"""
function decompose(ta::TimeArray)
    data_r = TimeSeries.values(log_returns(ta))
    return mean(data_r), std(data_r), cholesky(cor(data_r)).L
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
    mean_r, std_r, L = decompose(ta)
    P0 = TimeSeries.values(ta)[end, :]
    n = size(ta, 2)
    rates = Matrix{Float64}(undef, horizon, n)
    for day in 1:horizon
        rates[day, :] = L * randn(n) * std_r .+ mean_r
    end
    r_cum = exp.(vec(sum(rates, dims=1)))
    return sum(weights .* P0 .* r_cum)
end