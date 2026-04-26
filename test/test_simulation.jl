using Test
using Dates
using TimeSeries
using Statistics
using LinearAlgebra

include("../src/returns.jl")
include("../src/simulation.jl")


dates = [Date(2020, 1, 1) + Day(i) for i in 0:9]
prices = [100.0 200.0 150.0;
          101.0 199.0 152.0;
          103.0 201.0 149.0;
          102.0 203.0 151.0;
          104.0 202.0 153.0;
          105.0 204.0 150.0;
          103.0 203.0 152.0;
          106.0 205.0 154.0;
          104.0 204.0 151.0;
          107.0 206.0 155.0]
ta = TimeArray(dates, prices, [:A, :B, :C])


@testset "decompose" begin

    mean_r, std_r, L = decompose(ta)

    @testset "mean is a scalar" begin
        @test mean_r isa Float64
    end

    @testset "std is a scalar" begin
        @test std_r isa Float64
    end

    @testset "L is lower triangular" begin
        @test L isa LowerTriangular
        @test size(L) == (3, 3)
    end

    @testset "L recovers correlation matrix" begin
        data_r = TimeSeries.values(log_returns(ta))
        @test L * L' ≈ cor(data_r)
    end

    @testset "mean matches log returns" begin
        data_r = TimeSeries.values(log_returns(ta))
        @test mean_r ≈ mean(data_r)
    end

    @testset "std matches log returns" begin
        data_r = TimeSeries.values(log_returns(ta))
        @test std_r ≈ std(data_r)
    end

end