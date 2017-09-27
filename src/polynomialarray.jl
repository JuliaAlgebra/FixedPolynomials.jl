export PolynomialEvaluationArray, precompute!, evaluate!, unsafe_evaluate

"""
    PolynomialEvaluationArray(polynomials::Array{Polynomial{T}, N})

A structure for the fast evaluation of the given array `polynomials` of polynomials.
This provides a speedup about the separete evaluation of the polynomials since
as much computations as possible are shared over all polynomials of the array.
"""
struct PolynomialEvaluationArray{T, N}
    coefficients::Array{Vector{T}, N}
    lookuptables::Array{Matrix{Int}, N}
    diffs::Matrix{Int}
    values::Matrix{T}
end
function PolynomialEvaluationArray(polynomials::Array{Polynomial{T}, N}) where {T,N}
    nvars = nvariables(first(polynomials))
    @assert all(p -> nvariables(p) == nvars, polynomials) "All polynomials have to have the same number of variables"

    coeffs = coefficients.(polynomials)
    exps = exponents.(polynomials)

    ue = unique_exponents(vec(exps))
    lookuptables = map(exp -> lookuptable(exp, ue), exps)
    differences = differences!(ue)
    values = similar(differences, T)
    PolynomialEvaluationArray{T, N}(coeffs, lookuptables, differences, values)
end

"""
    precompute!(PEA::PolynomialEvaluationArray{T}, x::AbstractVector{T})

Precompute values for the evaluation of `PEA` at `x`.
"""
@inline function precompute!(PEA::PolynomialEvaluationArray{T}, x::AbstractVector{T}) where T
    fillvalues!(PEA.values, PEA.diffs, x)
end

"""
    evaluate!(u::AbstractArray{T,N}, PEA::PolynomialEvaluationArray{T,N}, x::AbstractVector{T})

Evaluate `PEA` at `x` and store the result in `u`. This will result in a call to [`precompute!`](@ref).
"""
function evaluate!(u::AbstractArray{T,N}, PEA::PolynomialEvaluationArray{T,N}, x::AbstractVector{T}) where {T,N}
    precompute!(PEA, x)
    for l in eachindex(PEA.lookuptables)
        lookuptable = PEA.lookuptables[l]
        coefficients = PEA.coefficients[l]
        u[l] = evaluate_lookuptable(lookuptable, PEA.values, coefficients)
    end
    u
end

"""
    unsafe_evaluate(PEA::PolynomialEvaluationArray{T,N}, I::Vararg{Int,N})

Evaluate the polynomial with index `I` in `PEA` for the value `x` for which the last call to [`precompute!`](@ref)
occured.

### Example
```julia
F = PolynomialEvaluationArray([f1 f2; f3 f4])
# assume now we are only interested on the entries f2 and f4
precompute!(F, x) #this is important!
unsafe_evaluate(F, 1, 2) == evaluate(f2, x)
unsafe_evaluate(F, 2, 2) == evaluate(f4, x)
```
"""
# It seems that the Vararg variant allocates, therefore we handroll for dimensions 1 to 3
function unsafe_evaluate(PEA::PolynomialEvaluationArray{T,1}, I::Int) where T
    lookuptable = PEA.lookuptables[I]
    coefficients = PEA.coefficients[I]
    evaluate_lookuptable(lookuptable, PEA.values, coefficients)
end
function unsafe_evaluate(PEA::PolynomialEvaluationArray{T,2}, i::Int, j::Int) where T
    lookuptable = PEA.lookuptables[i, j]
    coefficients = PEA.coefficients[i, j]
    evaluate_lookuptable(lookuptable, PEA.values, coefficients)
end
function unsafe_evaluate(PEA::PolynomialEvaluationArray{T,3}, i::Int, j::Int, k::Int) where T
    lookuptable = PEA.lookuptables[i, j, k]
    coefficients = PEA.coefficients[i, j, k]
    evaluate_lookuptable(lookuptable, PEA.values, coefficients)
end
function unsafe_evaluate(PEA::PolynomialEvaluationArray{T,N}, I::Vararg{Int,N}) where {T,N}
    lookuptable = PEA.lookuptables[I...]
    coefficients = PEA.coefficients[I...]
    evaluate_lookuptable(lookuptable, PEA.values, coefficients)
end
