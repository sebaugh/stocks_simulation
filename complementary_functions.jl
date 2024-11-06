# loading libraries used
using DataFrames
using Plots
using StatsBase
using LinearAlgebra
using ColorSchemes
using Random
using MarketData
using TimeSeries


function stocks_adjClose(tickers; years = 10)
    """
    Function used for downloading financial data from Yahoo finance for stocks specified by list of tickers. Due to different availability of the data the period is up to yesterday's date.
    
        Arguments:
        - tickers::string or list of strings - tickers of the stocks for which the data is downloaded
        - years - number of years for which the data is downloaded

        Returns:
        - stocks_close - DataFrame with columns named from tickers and values as the adjusted price closed.
    """

    stocks_close = []

    # downloading data iterating through tickers
    for ticker in tickers
        stock = DataFrame(yahoo(ticker, YahooOpt(period1 = now()- Year(years), period2 = now() - Day(1))))
        stock = stock.AdjClose
        push!(stocks_close, stock)
    end

    # transforming data to dataframe format
    stocks_close = DataFrame(reduce(hcat, stocks_close), tickers)
    return stocks_close
end