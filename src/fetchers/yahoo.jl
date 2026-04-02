using DataFrames
using Dates
using MarketData
using TimeSeries


"""
    stocks_adj_close(tickers; years=10)

Downloads adjusted close prices from Yahoo Finance for the given tickers.

# Arguments
- `tickers`: ticker symbol or list of ticker symbols
- `years`: number of years of historical data to download (default: 10)

# Returns
- `stocks_close`: DataFrame with tickers as column names and adjusted close prices as values
"""
function stocks_adj_close(tickers; years = 10)

    stocks_close = Vector{Vector{Float64}}()

    # downloading data iterating through tickers
    for ticker in tickers
        stock = yahoo(ticker, 
        YahooOpt(
            period1 = now()- Year(years), 
            period2 = now() - Day(1)))
        stock = DataFrame(stock).AdjClose
        push!(stocks_close, stock)
    end

    # transforming data to dataframe format
    stocks_close = DataFrame(reduce(hcat, stocks_close), tickers)
    return stocks_close
end