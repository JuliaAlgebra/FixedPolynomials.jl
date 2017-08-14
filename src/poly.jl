"""
    Poly(exponents, coeffs, homogenized=false)

A structure for fast multivariate Polynomial evaluation.

### Fields
* `exponents::Matrix{Int}`: Each column represents the exponent of a term. The columns are sorted lexicographically by total degree.
* `coeffs::Vector{T}`: List of the coefficients.

### Example
```
Poly: 3XYZ^2 - 2X^3Y
exponents:
    [ 3 1
      1 1
      0 2 ]
coeffs: [-2.0, 3.0]
```
"""
struct Poly{T<:Number}
    exponents::Matrix{Int}
    coeffs::Vector{T}
    homogenized::Bool

    function Poly{T}(exponents::Matrix{Int}, coeffs::Vector{T}, homogenized::Bool) where {T<:Number}
        sorted_cols = sort!([1:size(exponents,2);], lt=((i, j) -> lt_total_degree(exponents[:,i], exponents[:,j])), rev=true)

        new(exponents[:, sorted_cols], coeffs[sorted_cols], homogenized)
    end
end
function Poly(exponents::Matrix{Int}, coeffs::Vector{T}, homogenized::Bool) where {T<:Number}
    Poly{T}(exponents, coeffs, homogenized)
end

function Poly(exponents::Matrix{Int}, coeffs::Vector{T}; homogenized=false) where {T<:Number}
    Poly{T}(exponents, coeffs, homogenized)
end
function Poly(exponents::Vector{Int}, coeffs::Vector{<:Number}; homogenized=false)
    Poly(reshape(exponents, (length(exponents), 1), coeffs), homogenized)
end

==(p::Poly, q::Poly) = p.exponents == q.exponents && p.coeffs == q.coeffs

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

Base.eltype(p::Poly{T}) where {T} = T

"""
    exponents(p::Poly)

Returns the exponents matrix
"""
exponents(p::Poly) = p.exponents

"""
    coeffs(p::Poly)

Returns the coefficient vector
"""
coeffs(p::Poly) = p.coeffs

"""
    homogenized(p::Poly)

Checks whether `p` was homogenized.
"""
homogenized(p::Poly) = p.homogenized

"""
    nterms(p::Poly)

Returns the number of terms of p
"""
nterms(p::Poly) = size(exponents(p), 2)

"""
    nvars(p::Poly)

Returns the number of variables of p
"""
nvariables(p::Poly) = size(exponents(p), 1)

"""
    deg(p::Poly)

Returns the (total) degree of p
"""
deg(p::Poly) = sum(exponents(p)[:,1])


# ITERATOR
start(p::Poly) = (1, nterms(p))
function next(p::Poly, state::Tuple{Int,Int})
    (i, limit) = state
    newstate = (i + 1, limit)
    val = (coeffs(p)[i], exponents(p)[:,i])

    (val, newstate)
end
done(p::Poly, state) = state[1] > state[2]
length(p::Poly) = nterms(p)

# function getindex(f::Poly, I)
#     A = f.exponents
#     res = 1:size(A,2)
#     for i in eachindex(x)
#         res = res[find(y -> y == x[i], A[i,res])]
#         if isempty(res)
#             return zero(eltype(f))
#         end
#     end

#     f.coeffs[res[1]]
# end

"""
    evaluate(p::Poly{T}, x::AbstractVector{T})

Evaluates `p` at `x`, i.e. p(x)
"""
function evaluate(p::Poly{T}, x::AbstractVector{T})::T where {T<:Number}
    cfs = coeffs(p)
    exps = exponents(p)
    nvars, nterms = size(exps)
    res = zero(T)
    for j = 1:nterms
        term = cfs[j]
        for i = 1:nvars
            k = exps[i, j]
            term *= x[i]^k
        end
        res += term
    end
    res
end
(p::Poly{T})(x::Vector{T}) where {T<:Number} = evaluate(p, x)


"""
    differentiate(p::Poly, varindex)

Differentiates p w.r.t to the `varindex`th variable.
"""
function differentiate(p::Poly, i_var)
    exps = copy(exponents(p))
    n_vars, n_terms = size(exps)

    cfs = copy(coeffs(p))
    for j=1:n_terms
        k = exps[i_var, j]
        if k > 0
            exps[i_var, j] = max(0, k - 1)
            cfs[j] *= k
        else
            exps[:,j] = zeros(Int, n_vars, 1)
            cfs[j] = zero(eltype(p))
        end
    end
    Poly(exps, cfs, p.homogenized)
end


"""
    gradient(p::Poly)

Differentiates Poly `p`. Returns the gradient vector.
"""
gradient(p::Poly) = map(i -> differentiate(p, i), 1:nvariables(p))


"""
    ishomogenous(p::Poly)

Checks whether `p` is homogenous.
"""
function ishomogenous(p::Poly)
    monomials_degree = sum(exponents(p), 1)
    max_deg = monomials_degree[1]
    all(x -> x == max_deg, monomials_degree)
end

"""
    homogenize(p::Poly)

Makes `p` homogenous.
"""
function homogenize(p::Poly)
    if (p.homogenized)
        p
    else
        monomials_degree = sum(exponents(p), 1)
        max_deg = monomials_degree[1]
        Poly([max_deg - monomials_degree; exponents(p)], coeffs(p), homogenized=true)
    end
end

"""
    dehomogenize(p::Poly)

dehomogenizes `p`
"""
dehomogenize(p::Poly) = Poly(exponents(p)[2:end,:], coeffs(p), false)

"""
    multinomial(k::Vector{Int})

Computes the multinomial coefficient (|k| \\over k)
"""
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
    weyldot(f , g)

Compute the Bombieri-Weyl dot product between `Poly`s `f` and `g`.
Assumes that `f` and `g` are homogenous. See [here](https://en.wikipedia.org/wiki/Bombieri_norm)
for more details.
"""
function weyldot(f::Poly,g::Poly)
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

"""
    weylnorm(f::Poly)

Compute the Bombieri-Weyl norm for `f`. Assumes that `f` is homogenous.
See [here](https://en.wikipedia.org/wiki/Bombieri_norm) for more details.
"""
weylnorm(f::Poly) = √weyldot(f,f)
