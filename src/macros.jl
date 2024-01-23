
"""
# Examples

`@params 1, [1, 2, 3], "abc"`
"""
macro params(expr)
    if (expr isa Expr) && (expr.head == :tuple)
        return expr |> esc
    else
        return Expr(:tuple, expr) |> esc
    end
end

is_params_call(expr) = (expr.head == :macrocall) && (expr.args[1] == Symbol("@params"))

"""
# Examples

`@success out == 1`

`@success in[1] + in[2] == out`
"""
macro success()
    return Expr(:call, :(ParamTests.Success)) |> esc
end
macro success(expr)
    body = (expr.head == :tuple) ?
        Expr(:call, :all, Expr(:vect, expr.args...)) :
        expr
    assert = Expr(:->, Expr(:tuple, :in, :out), body)
    return Expr(:call, :(ParamTests.Success), assert) |> esc
end

is_success_call(expr) = (expr.head == :macrocall) && (expr.args[1] == Symbol("@success"))

"""
# Examples

`@failure BoundsError`
"""
macro failure()
    return Expr(:call, :(ParamTests.Failure)) |> esc
end
macro failure(expr)
    return Expr(:call, :(ParamTests.Failure), expr) |> esc
end

is_failure_call(expr) = (expr.head == :macrocall) && (expr.args[1] == Symbol("@failure"))

"""
# Examples

```
@param_test 
```
"""
macro param_test(unit, expr)
    Base.remove_linenums!(expr)
    assert_param_test_structure(expr)

    params = Expr[]
    expected = Expr[]
    for e in expr.args
        if is_params_call(e)
            push!(params, e)
        else
            while length(expected) < length(params)
                push!(expected, e)
            end
        end
    end

    params_var = gensym("params")
    expected_var = gensym("expected")

    return Expr(:block,
        Expr(:(=), params_var, Expr(:vect, params...)),
        Expr(:(=), expected_var, Expr(:vect, expected...)),
        Expr(:call, :(ParamTests.parametrized_test), unit, params_var, expected_var)
    ) |> esc
end

function assert_param_test_structure(expr)
    @assert all((is_params_call(e) || is_success_call(e) || is_failure_call(e) for e in expr.args))
    @assert is_params_call(expr.args[1])
    @assert is_success_call(expr.args[end]) || is_failure_call(expr.args[end])
end
