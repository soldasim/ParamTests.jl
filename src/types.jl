
abstract type Expected end

struct Success <: Expected
    assert
end
Success() = Success((in, out) -> true)

struct Failure <: Expected
    exception::Type

    function Failure(exception)
        @assert exception <: Exception
        new(exception)
    end
end
Failure() = Failure(Exception)
