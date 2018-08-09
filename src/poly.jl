export Polynomial, exponents, coefficients, variables, nvariables, nterms,
    ishomogenized, ishomogenous, homogenize, dehomogenize, degree, evaluate, substitute,
    differentiate, ∇, weylnorm, weyldot, scale_coefficients!

"""
    Polynomial(p::MultivariatePolynomials.AbstractPolynomial [, variables [, homogenized=false]])

A structure for fast evaluation of multivariate polynomials.
The terms are sorted first by total degree, then lexicographically.
`Polynomial` has first class support for [homogenous polynomials](https://en.wikipedia.org/wiki/Homogeneous_polynomial).
This field indicates whether the first variable should be considered as the homogenization variable.


    Polynomial{T}(p::MultivariatePolynomials.AbstractPolynomial [, variables [, homogenized=false]])


You can force a coefficient type `T`. For optimal performance `T` should be same type as
the input to with which it will be evaluated.


    Polynomial(exponents::Matrix{Int}, coefficients::Vector{T}, variables, [, homogenized=false])

You can also create a polynomial directly. Note that in exponents each column represents the exponent of a term.

### Example
```
Poly([3 1; 1 1; 0 2 ], [-2.0, 3.0], [:x, :y, :z]) == 3.0x^2yz^2 - 2x^3y
```
"""
mutable struct Polynomial{T<:Number}
    exponents::Matrix{Int}
    coefficients::Vector{T}
    variables::Vector{Symbol}
    homogenized::Bool

    function Polynomial{T}(exponents::Matrix{Int}, coefficients::Vector{T}, variables::Vector{Symbol}, homogenized::Bool) where {T<:Number}
        sorted_cols = sort!([1:size(exponents,2);], lt=((i, j) -> lt_total_degree(exponents[:,i], exponents[:,j])), rev=true)
        exps = exponents[:, sorted_cols]
        coeffs = coefficients[sorted_cols]
        new(exps, coeffs, copy(variables), homogenized)
    end
end

function Polynomial(exponents::Matrix{Int}, coefficients::Vector{T}, variables::Vector{Symbol}, homogenized::Bool=false) where {T<:Number}
    Polynomial{T}(exponents, coefficients, variables, homogenized)
end

function Polynomial(exponents::Matrix{Int}, coefficients::Vector{T}, homogenized::Bool=false) where {T<:Number}
    Polynomial{T}(exponents, coefficients, [Symbol("x$(i)") for i=1:size(exponents, 1)], homogenized)
end
function Polynomial(p::MP.AbstractPolynomialLike, variables::Vector{<:MP.AbstractVariable}, homogenized::Bool=false)
    exps, coefficients = _coefficients_exponents(p, variables)
    Polynomial(exps, coefficients, Symbol.(variables), homogenized)
end
Polynomial(p::MP.AbstractPolynomialLike, homogenized::Bool=false) = Polynomial(p, MP.variables(p), homogenized)

function Polynomial{T}(p::MP.AbstractPolynomialLike, variables::Vector{<:MP.AbstractVariable}, homogenized::Bool=false) where {T<:Number}
    exps, coefficients = _coefficients_exponents(p, variables)
    Polynomial{T}(exps, convert(Vector{T}, coefficients), Symbol.(variables), homogenized)
end
Polynomial{T}(p::MP.AbstractPolynomialLike, homogenized::Bool=false) where {T<:Number} = Polynomial{T}(p, MP.variables(p), homogenized)

function _coefficients_exponents(poly::MP.AbstractPolynomialLike{T}, vars) where {T}
    terms = MP.terms(poly)
    nterms = length(terms)
    nvars = length(vars)
    exps = Matrix{Int}(undef, nvars, nterms)
    coefficients = Vector{T}(undef, nterms)
    for j = 1:nterms
        term = terms[j]
        coefficients[j] = MP.coefficient(term)
        for i = 1:nvars
            exps[i,j] = MP.degree(term, vars[i])
        end
    end
    exps, coefficients
end

"Sorts two vectory by total degree"
function lt_total_degree(a::Vector{T}, b::Vector{T}) where {T<:Real}
    sum_a = sum(a)
    sum_b = sum(b)
    if sum_a < sum_b
        return true
    elseif sum_a > sum_b
        return false
    else
        for i in eachindex(a)
            if a[i] < b[i]
                return true
            elseif a[i] > b[i]
                return false
            end
        end
    end
    false
end

"""
    exponents(p::Polynomial)

Returns the exponents matrix of `p`. Each column represents the exponents of a term of `p`.
"""
exponents(p::Polynomial) = p.exponents

"""
    coefficients(p::Polynomial)

Returns the coefficient vector of `p`.
"""
coefficients(p::Polynomial) = p.coefficients

"""
    variables(p::Polynomial)

Returns the variables of `p`.
"""
variables(p::Polynomial) = p.variables

"""
    ishomogenized(p::Polynomial)

Checks whether `p` was homogenized.
"""
ishomogenized(p::Polynomial) = p.homogenized

"""
    nterms(p::Polynomial)

Returns the number of terms of p
"""
nterms(p::Polynomial) = size(exponents(p), 2)

"""
    nvariables(p::Polynomial)

Returns the number of variables of p
"""
nvariables(p::Polynomial) = size(exponents(p), 1)

"""
    degree(p::Polynomial)

Returns the (total) degree of p.
"""
degree(p::Polynomial) = sum(exponents(p)[:,1])


==(p::Polynomial, q::Polynomial) = exponents(p) == exponents(q) && coefficients(p) == coefficients(q)
Base.isequal(p::Polynomial, q::Polynomial) = exponents(p) == exponents(q) && coefficients(p) == coefficients(q)

# ITERATOR
function Base.iterate(p::Polynomial, state...)
    n = nterms(p)
    istate = iterate(1:n, state...)
    istate === nothing && return nothing

    i, state = istate
    (coefficients(p)[i], exponents(p)[:,i]), state
end
Base.length(p::Polynomial) = nterms(p)
Base.eltype(p::Polynomial{T}) where {T} = T

Base.broadcastable(p::Polynomial) = Ref(p)

@inline pow(x::AbstractFloat, k::Integer) = Base.FastMath.pow_fast(x, k)
#@inline pow(x::Complex, k::Integer) = k == 1 ? x : x^k
# simplified from Base.power_by_squaring
@inline function pow(x::Number, p::Integer)
    if p == 1
        return copy(x)
    elseif p == 0
        return one(x)
    elseif p == 2
        return x*x
    end
    t = trailing_zeros(p) + 1
    p >>= t
    while (t -= 1) > 0
        x *= x
    end
    y = x
    while p > 0
        t = trailing_zeros(p) + 1
        p >>= t
        while (t -= 1) >= 0
            x *= x
        end
        y *= x
    end
    return y
end

"""
    evaluate(p::Polynomial{T}, x::AbstractVector{T})

Evaluates `p` at `x`, i.e. ``p(x)``.
`Polynomial` is also callable, i.e. you can also evaluate it via `p(x)`.
"""
function evaluate(p::Polynomial{S}, x::AbstractVector{T}) where {S<:Number, T<:Number}
    cfs = coefficients(p)
    exps = exponents(p)
    nvars, nterms = size(exps)
    res = zero(promote_type(S,T))
    for j = 1:nterms
        term = p.coefficients[j]
        for i = 1:nvars
            k = exps[i, j]
            term *= pow(x[i], k)
        end
        res += term
    end
    res
end

(p::Polynomial)(x) = evaluate(p, x)

evaluate(F::Vector{<:Polynomial}, x::AbstractVector) = map(f -> evaluate(f, x), F)
"""
    substitute(p::Polynomial, i, x)

In `p` substitute for the variable with index `i` the value `x`. You can use this for partial
evaluation of polynomial.

### Example
```julia-repl
julia> substitute(x^2+3y, 2, 5)
x^2+15
```
"""
function substitute(p::Polynomial{S}, varindex, x::T) where {S<:Number, T<:Number}
    cfs = coefficients(p)
    exps = exponents(p)
    nvars, nterms = size(exps)

    new_coefficients = Vector{promote_type(S,T)}()
    new_exps = Vector{Vector{Int}}()

    for j = 1:nterms
        coeff = cfs[j]
        exp = Vector{Int}(undef, nvars - 1)
        # first we calculate the new coefficient and remove the varindex-th row
        for i = 1:nvars
            if i == varindex
                coeff *= x^(exps[i, j])
            elseif i > varindex
                exp[i-1] = exps[i, j]
            else
                exp[i] = exps[i, j]
            end
        end
        # now we have to delete possible duplicates
        found_duplicate = false
        for k = 1:length(new_exps)
            if new_exps[k] == exp
                new_coefficients[k] += coeff
                found_duplicate = true
                break
            end
        end
        if !found_duplicate
            push!(new_coefficients, coeff)
            push!(new_exps, exp)
        end
    end

    # now we have to create a new matrix and return the poly
    Polynomial(hcat(new_exps...), new_coefficients, [variables(p)[1:varindex-1]; variables(p)[varindex+1:end]], p.homogenized)
end

"""
    differentiate(p::Polynomial, varindex::Int)

Differentiate `p` w.r.t the `varindex`th variable.


    differentiate(p::Polynomial)

Differentiate `p` w.r.t. all variables.
"""
function differentiate(p::Polynomial{T}, i_var) where T
    exps = copy(exponents(p))
    cfs = copy(coefficients(p))
    n_vars, n_terms = size(exps)

    zerocolumns = Int[]
    for j=1:n_terms
        k = exps[i_var, j]
        if k > 0
            exps[i_var, j] = max(0, k - 1)
            cfs[j] *= k
        else
            push!(zerocolumns , j)
        end
    end

    # now we have to get rid of all zeros
    nzeros = length(zerocolumns)
    if nzeros == 0
        return Polynomial(exps, cfs, variables(p), p.homogenized)
    end

    skipped_cols = 0
    new_exps = zeros(Int, n_vars, n_terms - nzeros)
    new_coefficients = zeros(T, n_terms - nzeros)

    for j = 1:n_terms
        # if we not yet have skipped all zero columns
        if skipped_cols < nzeros && j == zerocolumns[skipped_cols+1]
            skipped_cols += 1
            continue
        end

        new_exps[:, j - skipped_cols] = exps[:, j]
        new_coefficients[j - skipped_cols] = cfs[j]
    end

    Polynomial(new_exps, new_coefficients, variables(p), p.homogenized)
end
differentiate(poly::Polynomial) = map(i -> differentiate(poly, i), 1:nvariables(poly))

"""
    ∇(p::Polynomial)

Returns the gradient vector of `p`. This is the same as [`differentiate`](@ref).
"""
@inline ∇(poly::Polynomial) = differentiate(poly)

"""
    ishomogenous(p::Polynomial)

Checks whether `p` is a homogenous polynomial. Note that this is unaffected from the
value of `homogenized(p)`.
"""
function ishomogenous(p::Polynomial)
    monomials_degree = sum(exponents(p), dims=1)
    max_deg = monomials_degree[1]
    all(x -> x == max_deg, monomials_degree)
end

"""
    homogenize(p::Polynomial [, variable = :x0])

Makes `p` homogenous, if `ishomogenized(p)` is `true` this is just the identity.
The homogenization variable will always be considered as the first variable of the polynomial.
"""
function homogenize(p::Polynomial, variable::Symbol=:x0; respect_homogenous=true)
    if p.homogenized || (respect_homogenous && ishomogenous(p))
        p
    else
        monomials_degree = sum(exponents(p), dims=1)
        max_deg = monomials_degree[1]
        Polynomial([max_deg .- monomials_degree; exponents(p)], coefficients(p), [variable; variables(p)], true)
    end
end

"""
    dehomogenize(p::Polynomial)

Substitute `1` as for the first variable `p`, if `ishomogenized(p)` is `false` this is just
the identity.
"""
function dehomogenize(p::Polynomial)
    if !p.homogenized
        p
    else
        Polynomial(exponents(p)[2:end,:], coefficients(p), variables(p)[2:end], false)
    end
end

"Computes the multinomial coefficient (|k| \\over k)"
function multinomial(k::Vector{Int})
    s = 0
    result = 1
    @inbounds for i in k
        s += i
        result *= binomial(s, i)
    end
    result
end

"""
    weyldot(f::Polynomial, g::Polynomial)

Compute the [Bombieri-Weyl dot product](https://en.wikipedia.org/wiki/Bombieri_norm).
Note that this is only properly defined if `f` and `g` are homogenous.

    weyldot(f::Vector{Polynomial}, g::Vector{Polynomial})

Compute the dot product for vectors of polynomials.
"""
function weyldot(f::Polynomial,g::Polynomial)
    if (f === g)
        return sum(x -> abs2(x[1]) / multinomial(x[2]), f)
    end
    result = 0
    for (c_f, exp_f) in f
        normalizer = multinomial(exp_f)
        for (c_g, exp_g) in g
            if exp_f == exp_g
                result += (c_f * conj(c_g)) / normalizer
                break
            end
        end
    end
    result
end

function weyldot(F::Vector{Polynomial{T}}, G::Vector{Polynomial{S}}) where {T,S}
    res = zero(promote_type(S, T))
    for (f, g) in zip(F, G)
        res += weyldot(f, g)
    end
    res
end

"""
    weylnorm(f::Polynomial)

Compute the [Bombieri-Weyl norm](https://en.wikipedia.org/wiki/Bombieri_norm).
Note that this is only properly defined if `f` is homogenous.
"""
weylnorm(f::Polynomial) = √weyldot(f,f)
weylnorm(f::Vector{Polynomial{T}}) where T = √weyldot(f,f)


"""
    scale_coefficients!(f::Polynomial, λ)

Scale the coefficients of `f` with the factor `λ`.
"""
function scale_coefficients!(f::Polynomial, λ)
    f.coefficients .*= λ
end
