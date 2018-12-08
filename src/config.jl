export GradientConfig, GradientDiffResult, config,
    gradient!, evaluate, evaluate!, jacobian, jacobian!, value

const Index = UInt16
const Delimiter = UInt16
const Exponent = UInt16

mutable struct PolyConfig{T}
    monomials_delimiters::Vector{Delimiter}
    monomials::Vector{Index}
    grad_monomials_delimiters::Vector{Vector{Tuple{Delimiter, Exponent}}}
    grad_monomials::Vector{Vector{Index}}
    reduced_exponents_delimiters::Vector{Delimiter}
    reduced_exponents_map::Vector{Tuple{Index, Exponent}}
    reduced_values::Vector{T}
end

function PolyConfig(g::Polynomial{T}, reduced_exponents::Matrix{UInt16}, big_lookup::Matrix{<:Integer}, ::Type{S}) where {T, S}
    exponents = g.exponents
    m, n = size(reduced_exponents)

    reduced_exponents_delimiters = Vector{UInt16}(undef, n)
    reduced_exponents_map = Vector{NTuple{2, UInt16}}()
    for j=1:n
        nindices = 0
        for i=1:m
            if reduced_exponents[i, j] > 0
                nindices += 1
                push!(reduced_exponents_map, (convert(UInt16, i), big_lookup[i, j]))
            end
        end
        reduced_exponents_delimiters[j] = nindices
    end

    # monomials_full = BitMatrix(exponents)
    monomials_delimiters = Vector{UInt16}(undef, n)
    monomials = Vector{UInt16}()
    for j=1:n
        nindices = 0
        for i=1:m
            if exponents[i, j] > 0
                nindices += 1
                push!(monomials, convert(UInt16, i))
            end
        end
        monomials_delimiters[j] = nindices
    end

    grad_monomials_delimiters = Vector{Vector{Tuple{Delimiter, Exponent}}}(undef, m)
    grad_monomials = Vector{Vector{Index}}(undef, m)
    for varindex = 1:m
        imonomials_delimiters = Vector{Tuple{Delimiter, Exponent}}(undef, n)
        imonomials = Vector{Index}()
        for j=1:n
            nindices = 0
            k = exponents[varindex, j]
            if k > 0
                for i=1:m
                    if exponents[i, j] > 0 && i != varindex
                        nindices += 1
                        push!(imonomials, i)
                    end
                end
            end
            imonomials_delimiters[j] = (nindices, k)
        end
        grad_monomials[varindex] = imonomials
        grad_monomials_delimiters[varindex] = imonomials_delimiters
    end

    PolyConfig(
        monomials_delimiters,
        monomials,
        grad_monomials_delimiters,
        grad_monomials,
        reduced_exponents_delimiters,
        reduced_exponents_map,
        zeros(typeof(one(T) * one(S) + one(T) * one(S)), n))
end

Base.show(io::IO, C::PolyConfig) = print(io, typeof(C), "()")
function fillreduced_values!(
    cfg::PolyConfig{T},
    g::Polynomial,
    x::AbstractVector,
    diffs_values::AbstractMatrix{T}) where T
    v = cfg.reduced_values
    reds = cfg.reduced_exponents_delimiters
    rem = cfg.reduced_exponents_map
    dv = diffs_values
    cfs = g.coefficients

    N = length(rem)
    n = length(reds)
    k = 1
    j = 1
    nextj_at = j + reds[j]
    @inbounds res = convert(T, cfs[j])
    while k ≤ N || j < n
        togo = nextj_at - k
        if togo == 0
            @inbounds v[j] = res
            j += 1
            @inbounds nextj_at += reds[j]
            @inbounds res = convert(T, cfs[j])
        else
            @inbounds i, l = rem[k]
            @inbounds res *= dv[i, l]
            k += 1
        end
    end
    @inbounds v[j] = res
    v
end


@inline function fillvalues!(
    values::AbstractMatrix{T},
    xs::AbstractVector,
    diffs) where T
    m, n = size(values)
    if n == 0
        return values
    end
    for i=1:m
        @inbounds l = diffs[i,1]
        xi = xs[i]
        v = l == 0 ? one(T) : pow(xi, l)
        @inbounds values[i, 1] = v
        for k=2:n
            @inbounds l = diffs[i,k]
            v = l == 0 ? v : v * pow(xi, l)
            @inbounds values[i,k] = v
        end
    end
    nothing
end

@inline function _evaluate(x::AbstractVector, cfg::PolyConfig{T}) where T
    v = cfg.reduced_values
    mds = cfg.monomials_delimiters
    ms = cfg.monomials

    N = length(ms)
    n = length(mds)
    k = 1
    j = 1
    @inbounds nextj_at = j + mds[j]
    @inbounds res = v[j]
    out = zero(T)
    while k ≤ N || j < n
        if k == nextj_at
            out += res
            j += 1
            @inbounds nextj_at += mds[j]
            @inbounds res = v[j]
        else
            res *= x[ms[k]]
            k += 1
        end
    end
    out += res

    out
end

@inline function _gradient!(u::AbstractVector, x::AbstractVector, cfg::PolyConfig{T}) where T
    v = cfg.reduced_values
    gmds = cfg.grad_monomials_delimiters
    gms = cfg.grad_monomials

    for i=1:length(gmds)
        @inbounds ui = _gradient(v, gmds[i], gms[i], x)
        u[i] = ui
    end
    u
end

"""
    gradient_row!(u::AbstractMatrix, x::AbstractVector, cfg::PolyConfig{T}, i)
Store the gradient in the i-th row of 'u'.
"""
@inline function gradient_row!(u::AbstractMatrix, x::AbstractVector, cfg::PolyConfig{T}, i) where T
    v = cfg.reduced_values
    gmds = cfg.grad_monomials_delimiters
    gms = cfg.grad_monomials

    for j=1:length(gmds)
        @inbounds uij = _gradient(v, gmds[j], gms[j], x)
        u[i, j] = uij
    end
    u
end

function _gradient(v::AbstractVector{T}, mds, ms, x) where T
    N = length(ms)
    n = length(mds)
    k = 1
    j = 1
    @inbounds delim, exponent = mds[j]
    nextj_at = j + delim
    @inbounds res = v[j] * exponent
    out = zero(T)
    while k ≤ N || j < n
        if k == nextj_at
            out += res
            j += 1
            @inbounds delim, exponent = mds[j]
            nextj_at += delim
            @inbounds res = exponent == 0 ? zero(T) : v[j] * exponent
        else
            res *= x[ms[k]]
            k += 1
        end
    end
    out += res
    out
end

"""
    GradientConfig(f::Polynomial{T}, [x::AbstractVector{S}])

A data structure with which the gradient of a `Polynomial` `f` can be
evaluated efficiently. Note that `x` is only used to determine the
output type of `f(x)`.

    GradientConfig(f::Polynomial{T}, [S])

Instead of a vector `x` a type can also be given directly.
"""
mutable struct GradientConfig{T}
    poly::PolyConfig{T}
    differences::Matrix{UInt8}
    differences_values::Matrix{T}
end

function GradientConfig(f::Polynomial{T}, ::AbstractArray{S}) where {T, S}
    GradientConfig(f, S)
end
GradientConfig(f::Polynomial{T}) where T = GradientConfig(f, T)
function GradientConfig(f::Polynomial{T}, ::Type{S}) where {T, S}
    diffs, diffs_values, big_lookup, reduced_exponents = differences(f, S)
    poly = PolyConfig(f, reduced_exponents, big_lookup, S)

    GradientConfig(poly, diffs, diffs_values)
end

Base.show(io::IO, C::GradientConfig) = print(io, typeof(C), "()")

"""
    config(F::Polynomial, x)

Construct a `GradientConfig` for the evaluation of `f` with values like `x`.
"""
function config(f::Polynomial{T}, x::AbstractVector{S}) where {S, T}
    GradientConfig(f, typeof(one(T) * one(S) + one(T) * one(S)))
end

function differences(f::Polynomial{T}, ::Type{S}) where {T, S}
    exponents = f.exponents
    reduced_exponents = convert.(UInt16, max.(exponents .- 1, 0))
    differences, big_lookup = computetables(reduced_exponents)
    differences_values = convert.(promote_type(T, S), differences)

    differences, differences_values, big_lookup, reduced_exponents
end


# function Base.deepcopy(cfg::GradientConfig)
#     GradientConfig(
#         deepcopy(cfg.poly),
#         deepcopy(cfg.differences),
#         deepcopy(cfg.differences_values))
# end

"""
    evaluate(g, x, cfg::GradientConfig [, precomputed=false])

Evaluate `g` at `x` using the precomputated values in `cfg`.
Note that this is usually signifcant faster than `evaluate(g, x)`.

### Example
```julia
cfg = GradientConfig(g)
evaluate(g, x, cfg)
```

With `precomputed=true` we rely on the previous intermediate results in `cfg`. Therefore
the result is only correct if you previouls called `evaluate`, or `gradient` with the same
`x`.
"""
function evaluate(g::Polynomial, x::AbstractVector, cfg::GradientConfig{T}, precomputed=false) where T
    if !precomputed
        fillvalues!(cfg.differences_values, x, cfg.differences)
        fillreduced_values!(cfg.poly, g, x, cfg.differences_values)
    end
    _evaluate(x, cfg.poly)
end

"""
    gradient(g, x, cfg::GradientConfig[, precomputed=false])

Compute the gradient of `g` at `x` using the precomputated values in `cfg`.
The return vector is constructed using `similar(x, T)`.

### Example
```julia
cfg = GradientConfig(g)
gradient(g, x, cfg)
```

With `precomputed=true` we rely on the previous intermediate results in `cfg`. Therefore
the result is only correct if you previouls called `evaluate`, or `gradient` with the same
`x`.
"""
function gradient(g::Polynomial, x::AbstractVector, cfg::GradientConfig{T}, precomputed=false) where T
    u = similar(x, T, nvariables(g))
    gradient!(u, g, x, cfg, precomputed)
    u
end

"""
    gradient!(u, g, x, cfg::GradientConfig [, precomputed=false])

Compute the gradient of `g` at `x` using the precomputated values in `cfg`
and store thre result in u.

### Example
```julia
cfg = GradientConfig(g)
gradient(u, g, x, cfg)
```

With `precomputed=true` we rely on the previous intermediate results in `cfg`. Therefore
the result is only correct if you previouls called `evaluate`, or `gradient` with the same
`x`.
"""
function gradient!(u::AbstractVector, g::Polynomial, x::AbstractVector, cfg::GradientConfig{T}, precomputed=false) where T
    if !precomputed
        fillvalues!(cfg.differences_values, x, cfg.differences)
        fillreduced_values!(cfg.poly, g, x, cfg.differences_values)
    end
    _gradient!(u, x, cfg.poly)
end


"""
    GradientDiffResult(cfg::GradientConfig)

During the computation of ``∇g(x)`` we compute nearly everything we need for the evaluation of
``g(x)``. GradientDiffResult allocates memory to hold both values.
This structure also signals `gradient!` to store ``g(x)`` and ``∇g(x)``.

### Example

```julia
cfg = GradientConfig(g, x)
r = GradientDiffResult(cfg)
gradient!(r, g, x, cfg)

value(r) == g(x)
gradient(r) == gradient(g, x, cfg)
```

    GradientDiffResult(grad::AbstractVector)

Allocate the memory to hold the gradient by yourself.
"""
mutable struct GradientDiffResult{T, AV<:AbstractVector{T}}
    value::T
    grad::AV
end

function GradientDiffResult(cfg::GradientConfig{T}) where T
    GradientDiffResult{T, Vector{T}}(zero(T), Vector{T}(undef, size(cfg.differences, 1)))
end
function GradientDiffResult(grad::AbstractVector{T}) where T
    GradientDiffResult{T, Vector{T}}(zero(T), grad)
end

"""
    value(r::GradientDiffResult)

Get the currently stored value in `r`.
"""
value(r::GradientDiffResult) = r.value

"""
    gradient(r::GradientDiffResult)

Get the currently stored gradient in `r`.
"""
gradient(r::GradientDiffResult) = r.grad


"""
    gradient!(r::GradientDiffResult, g, x, cfg::GradientConfig)

Compute ``g(x)`` and the gradient of `g` at `x` at once using the precomputated values in `cfg`
and store thre result in `r`. This is faster than calling both values separetely.

### Example
```julia
cfg = GradientConfig(g)
r = GradientDiffResult(r)
gradient!(r, g, x, cfg)

value(r) == g(x)
gradient(r) == gradient(g, x, cfg)
```
"""
function gradient!(diffresult::GradientDiffResult, g::Polynomial, x::AbstractVector, cfg::GradientConfig{T}) where T
    fillvalues!(cfg.differences_values, x, cfg.differences)
    fillreduced_values!(cfg.poly, g, x, cfg.differences_values)
    diffresult.value = _evaluate(x, cfg.poly)
    _gradient!(diffresult.grad, x, cfg.poly)
    diffresult
end
