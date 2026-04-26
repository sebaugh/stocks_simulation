using Dates
using MarketData
using TimeSeries


"""
    stocks_data(tickers; years=10)

Downloads OHLCV data from Yahoo Finance for the given tickers.

# Arguments
- `tickers`: ticker symbol or list of ticker symbols
- `years`: number of years of historical data to download (default: 10)

# Returns
- `Dict` mapping each ticker to a TimeArray with columns: Open, High, Low, Close, AdjClose, Volume
"""
function stocks_data(tickers; years = 10)

    ticker_list = tickers isa AbstractString ? [tickers] : tickers
    data = Dict{String, TimeArray}()

    for ticker in ticker_list
        data[ticker] = MarketData.yahoo(ticker,
        YahooOpt(
            period1 = now() - Year(years),
            period2 = now() - Day(1)))
    end

    return data
end

"""
    get_field(data, field)

Downloads the specified field (e.g. :AdjClose) for the given tickers.

# Arguments
- `data`: a dictionary mapping ticker symbols to TimeArrays
- `field`: the field to download (e.g. :AdjClose)

# Returns
- `TimeArray` with columns for each ticker and rows indexed by date
"""
function get_field(data::Dict{String, TimeArray}, field)

    tickers = sort(collect(keys(data)))

    field_data = [TimeArray(timestamp(data[ticker][field]), Float64.(values(data[ticker][field])), colnames(data[ticker][field])) for ticker in tickers]
    combined = reduce((x, y) -> merge(x, y), field_data)

    return TimeArray(timestamp(combined), values(combined), Symbol.(tickers))
end
