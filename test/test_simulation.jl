using Test
using LinearAlgebra
using Random


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


@testset "model" begin

    weights = [0.5, 0.3, 0.2]

    @testset "returns a scalar" begin
        Random.seed!(42)
        @test model(ta, 10, weights) isa Float64
    end

    @testset "result is positive" begin
        Random.seed!(42)
        @test model(ta, 10, weights) > 0
    end

    @testset "reproducible with fixed seed" begin
        Random.seed!(42)
        v1 = model(ta, 10, weights)
        Random.seed!(42)
        v2 = model(ta, 10, weights)
        @test v1 == v2
    end

    @testset "different weights give different results" begin
        Random.seed!(42)
        v1 = model(ta, 10, [0.5, 0.3, 0.2])
        Random.seed!(42)
        v2 = model(ta, 10, [0.2, 0.3, 0.5])
        @test v1 != v2
    end

end

@testset "run_simulation" begin

    weights = [0.5, 0.3, 0.2]

    @testset "returns a vector" begin
        Random.seed!(42)
        @test run_simulation(100, ta, 10, weights) isa Vector{Float64}
    end

    @testset "vector has correct length" begin
        Random.seed!(42)
        sim_values = run_simulation(100, ta, 10, weights)
        @test length(sim_values) == 100
    end

    @testset "all values are positive" begin
        Random.seed!(42)
        sim_values = run_simulation(100, ta, 10, weights)
        @test all(v -> v > 0, sim_values)
    end

end