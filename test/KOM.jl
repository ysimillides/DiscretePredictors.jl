# Test ActiveLeZi Predictor

@testset "KOM" begin

p       = KOM{Char}(2);
data    = [ 'a', 'b', 'c', 'c', 'd',
            'b', 'c', 'd', 'c', 'b',
            'c', 'b', 'c' ];

@testset "Online Prediction" begin
    # Create model
    for symbol ∈ data
        add!( p, symbol );
        predictions     = predict( p );
        @test mapreduce(sym->predictions[sym],+,keys(predictions)) ≈ 1.00
    end
end

# Test model
test_model = Dict{Vector{Char},Int64}(
    ['a'] => 1,
    ['a','b'] => 1,
    ['a','b','c'] => 1,
    ['b'] => 4,
    ['b','c'] => 4,
    ['b','c','b'] => 1,
    ['b','c','c'] => 1,
    ['b','c','d'] => 1,
    ['c'] => 6,
    ['c','b'] => 2,
    ['c','b','c'] => 2,
    ['c','c'] => 1,
    ['c','c','d'] => 1,
    ['c','d'] => 2,
    ['c','d','b'] => 1,
    ['c','d','c'] => 1,
    ['d'] => 2,
    ['d','b'] => 1,
    ['d','b','c'] => 1,
    ['d','c'] => 1,
    ['d','c','b'] => 1
);


@testset "Model Tests" begin
    # Verify Model
    @testset "Values" begin
        @test p.model.value == 13;
        for node ∈ keys( test_model )
            @test p.model[node] == test_model[node];
        end
    end

    # Verify no other nodes exists
    @testset "Nodes" begin
        nodes   = keys( test_model )
        for node in keys( p.model )
            @test node ∈ nodes;
        end
    end

    @testset "Symbol Prediction" begin
        sym_probability = predict( p );
        @test sym_probability['a']  ≈   1/312;
        @test sym_probability['b']  ≈ 108/312;
        @test sym_probability['c']  ≈  97/312;
        @test sym_probability['d']  ≈ 106/312;
    end

    @testset "Model Size" begin
        @test size( p ) == 22;
    end
end

@testset "Best Symbol" begin
    # Reusing p
    @test get_best_symbol( p ) == 'b'
    # For untrained model
    @test get_best_symbol( KOM{Int64}(10) ) == nothing
    @test get_best_symbol( KOM{Char}(10) ) == nothing
    @test get_best_symbol( KOM{String}(10) ) == nothing
end

@testset "Info tests" begin
    @test info_string( p ) == "KOM(2)";
    @test unique_string( p ) == "KOM_02";
end

@testset "Random Sequence test" begin
    for idx = 1:10
        learnt_model    = KOM{Int64}(5);
        @test @test_nothrow for i = 1:1000
            symbol = trunc(Int64,10*rand());
            add!( learnt_model, symbol );
            predict( learnt_model );
        end
    end
end

end

nothing
