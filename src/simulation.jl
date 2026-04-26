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