export PolynomialEvaluationArray, fillvalues!, evaluate!, unsafe_evaluate

"""
    PolynomialEvaluationArray(polynomials::Array{Polynomial{T}, N})

A structure for the fast evaluation of the given array `polynomials` of polynomials.
This provides a speedup about the evaluation of the polynomials separetly since it
shares as much computations as possible over all polynomials.
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
    precompute!(pea::PolynomialEvaluationArray{T}, x::AbstractVector{T})

Precompute values for the evaluation of `pea` at `x`.
"""
@inline function precompute!(pea::PolynomialEvaluationArray{T}, x::AbstractVector{T}) where T
    fillvalues!(pea.values, pea.diffs, x)
end

"""
    evaluate!(u::AbstractArray{T,N}, pea::PolynomialEvaluationArray{T,N}, x::AbstractVector{T})

Evaluate `pea` at `x` and store the result in `u`. This will result in a call to [precompute!](@ref).
"""
function evaluate!(u::AbstractArray{T,N}, pea::PolynomialEvaluationArray{T,N}, x::AbstractVector{T}) where {T,N}
    precompute!(pea, x)
    for l in eachindex(pea.lookuptables)
        lookuptable = pea.lookuptables[l]
        coefficients = pea.coefficients[l]
        u[l] = evaluate_lookuptable(lookuptable, pea.values, coefficients)
    end
    u
end

"""
    unsafe_evaluate(pea::PolynomialEvaluationArray{T,N}, I::Vararg{Int,N})

Evaluate the polynomial with index `I` in `pea` for the value `x` for which the last call to [precompute!](@ref)
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
function unsafe_evaluate(pea::PolynomialEvaluationArray{T,N}, I::Vararg{Int,N}) where {T,N}
    lookuptable = pea.lookuptables[I...]
    coefficients = pea.coefficients[I...]
    evaluate_lookuptable(lookuptable, pea.values, coefficients)
end
function unsafe_evaluate(pea::PolynomialEvaluationArray{T,N}, I::Int) where {T,N}
    lookuptable = pea.lookuptables[I]
    coefficients = pea.coefficients[I]
    evaluate_lookuptable(lookuptable, pea.values, coefficients)
end
