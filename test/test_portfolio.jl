using Test


# Fixed input: 4 time steps, 2 tickers
dates = Date(2024,1,1):Day(1):Date(2024,1,4) |> collect
returns = TimeArray(dates, [0.01 0.02; 0.03 0.01; 0.02 0.04; 0.01 0.03], [:A, :B])


@testset "portfolio_mean" begin

    @testset "equal weights" begin
        weights = [0.5, 0.5]
        expected = sum(weights .* mean(TimeSeries.values(returns), dims=1))
        @test portfolio_mean(weights, returns) ≈ expected
    end

    @testset "unequal weights" begin
        weights = [0.8, 0.2]
        expected = sum(weights .* mean(TimeSeries.values(returns), dims=1))
        @test portfolio_mean(weights, returns) ≈ expected
    end

end


@testset "portfolio_variance" begin

    @testset "matches manual calculation" begin
        weights = [0.5, 0.5]
        expected = weights' * cov(TimeSeries.values(returns)) * weights
        @test portfolio_variance(weights, returns) ≈ expected
    end

end


@testset "optimize_portfolio" begin

    var_max = 1.0
    weights = optimize_portfolio(returns, var_max)

    @testset "weights sum to 1" begin
        @test sum(weights) ≈ 1.0
    end

    @testset "weights are non-negative" begin
        @test all(w -> w >= 0, weights)
    end

    @testset "variance satisfies constraint" begin
        @test portfolio_variance(weights, returns) <= var_max + 1e-6
    end

    @testset "returns correct number of weights" begin
        @test length(weights) == size(returns, 2)
    end

end
