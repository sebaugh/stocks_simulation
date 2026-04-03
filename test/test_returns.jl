using Test
using Dates
using TimeSeries

include("../src/returns.jl")


# fixed input for all tests
dates = [Date(2020, 1, 1) + Day(i) for i in 0:3]
prices = [100.0 200.0;
          110.0 210.0;
          105.0 220.0;
          115.0 190.0]
ta = TimeArray(dates, prices, [:AAPL, :MSFT])


@testset "cumulative_returns" begin

    result = cumulative_returns(ta)

    @testset "returns a TimeArray" begin
        @test result isa TimeArray
    end

    @testset "preserves timestamps" begin
        @test timestamp(result) == timestamp(ta)
    end

    @testset "preserves column names" begin
        @test colnames(result) == [:AAPL, :MSFT]
    end

    @testset "first row is all ones" begin
        @test all(TimeSeries.values(result)[1, :] .== 1.0)
    end

    @testset "correct prices" begin
        @test TimeSeries.values(result)[:, 1] ≈ [1.0, 1.1, 1.05, 1.15]
        @test TimeSeries.values(result)[:, 2] ≈ [1.0, 1.05, 1.1, 0.95]
    end

end


@testset "log_returns" begin

    result = log_returns(ta)

    @testset "returns a TimeArray" begin
        @test result isa TimeArray
    end

    @testset "drops first row" begin
        @test size(result, 1) == size(ta, 1) - 1
    end

    @testset "timestamps start from second day" begin
        @test timestamp(result) == timestamp(ta)[2:end]
    end

    @testset "preserves column names" begin
        @test colnames(result) == [:AAPL, :MSFT]
    end

    @testset "correct prices" begin
        @test TimeSeries.values(result)[:, 1] ≈ log.([110, 105, 115] ./ [100, 110, 105])
        @test TimeSeries.values(result)[:, 2] ≈ log.([210, 220, 190] ./ [200, 210, 220])
    end

end
