using Test

@testset "StocksSimulation" begin
    include("fetchers/test_yahoo.jl")
    include("test_returns.jl")
end
