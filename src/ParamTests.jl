module ParamTests

export @param_test, @params, @success, @failure

using Test

include("types.jl")
include("macros.jl")

parametrized_test(unit, params::AbstractVector{<:Tuple}, expected::AbstractVector{<:Expected}) =
    parametrized_test.(eachindex(expected), Ref(unit), params, expected)

parametrized_test(idx, script, inputs, exp::Success) = @testset "$idx" begin @test exp.assert(inputs, script(inputs...)) end
parametrized_test(idx, script, inputs, exp::Failure) = @testset "$idx" begin @test_throws exp.exception script(inputs...) end

end
