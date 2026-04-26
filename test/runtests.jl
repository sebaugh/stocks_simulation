using Test
using StocksSimulation
using TimeSeries
using Dates
using Statistics

@testset "StocksSimulation" begin
    include("fetchers/test_yahoo.jl")
    include("test_returns.jl")
    include("test_portfolio.jl")
    include("test_simulation.jl")
end
