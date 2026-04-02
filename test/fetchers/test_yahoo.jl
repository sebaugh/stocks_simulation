using Test
using Dates
using TimeSeries

include("../../src/fetchers/yahoo.jl")


@testset "stocks_data" begin

    result = stocks_data(["AAPL", "MSFT"]; years = 1)

    @testset "returns a Dict" begin
        @test result isa Dict
    end

    @testset "keys match tickers" begin
        @test sort(collect(keys(result))) == ["AAPL", "MSFT"]
    end

    @testset "values are TimeArrays" begin
        @test result["AAPL"] isa TimeArray
        @test result["MSFT"] isa TimeArray
    end

    @testset "correct columns" begin
        @test all(col in colnames(result["AAPL"]) for col in [:Open, :High, :Low, :Close, :AdjClose, :Volume])
    end

    @testset "correct number of rows" begin
        @test size(result["AAPL"], 1) > 0
    end

end
