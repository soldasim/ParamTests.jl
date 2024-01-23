using ParamTests
using Test

function basic_test()
    @param_test (x,y)->x+y begin
        @params 1, 2
        @success out == 3
    end
end

@testset "ParamTests.jl" begin
    # TODO: add unit tests
    basic_test()
end
