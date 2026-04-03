using TimeSeries


"""
    cumulative_returns(ta)

Computes cumulative returns relative to the first day for each ticker.

# Arguments
- `ta`: TimeArray with tickers as columns

# Returns
- `TimeArray` with each column divided by its first value
"""
function cumulative_returns(ta::TimeArray)
    values = TimeSeries.values(ta)
    return TimeArray(timestamp(ta), values ./ values[1:1, :], colnames(ta))
end


"""
    log_returns(ta)

Computes daily log returns for each ticker.

# Arguments
- `ta`: TimeArray with tickers as columns

# Returns
- `TimeArray` of log returns with the first row dropped
"""
function log_returns(ta::TimeArray)
    values = TimeSeries.values(ta)
    log_values = log.(values) - log.(circshift(values, (1, 0)))
    return TimeArray(timestamp(ta)[2:end], log_values[2:end, :], colnames(ta))
end
