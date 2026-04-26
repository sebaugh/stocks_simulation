using Test


@testset "yahoo fetcher" begin

    data = stocks_data(["AAPL", "MSFT"]; years = 1)

    @testset "stocks_data" begin

        @testset "returns a Dict" begin
            @test data isa Dict
        end

        @testset "keys match tickers" begin
            @test sort(collect(keys(data))) == ["AAPL", "MSFT"]
        end

        @testset "values are TimeArrays" begin
            @test data["AAPL"] isa TimeArray
            @test data["MSFT"] isa TimeArray
        end

        @testset "correct columns" begin
            @test all(col in colnames(data["AAPL"]) for col in [:Open, :High, :Low, :Close, :AdjClose, :Volume])
        end

        @testset "correct number of rows" begin
            @test size(data["AAPL"], 1) > 0
        end

    end

    if data isa Dict && all(v isa TimeArray for v in values(data))

        @testset "get_field" begin

            result = get_field(data, :AdjClose)

            @testset "returns a TimeArray" begin
                @test result isa TimeArray
            end

            @testset "columns match tickers" begin
                @test sort(collect(string.(colnames(result)))) == ["AAPL", "MSFT"]
            end

            @testset "correct number of rows" begin
                @test size(result, 1) > 0
            end

            @testset "single column per ticker" begin
                @test size(result, 2) == 2
            end

        end

    end

end
