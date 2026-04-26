using Test

@testset "StocksSimulation" begin
    include("fetchers/test_yahoo.jl")
    include("test_returns.jl")
    include("test_portfolio.jl")
    include("test_simulation.jl")
end
