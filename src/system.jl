export System,
    JacobianConfig, JacobianDiffResult,
    evaluate_and_jacobian!, evaluate_and_jacobian

"""
    System(polys [, variables])

Construct a system of polynomials from the given polynomials `polys`.
"""
struct System{T}
    polys::Vector{Polynomial{T}}
end

function System(polys::Vector{<:MP.AbstractPolynomialLike}, variables=_variables(polys))
    System([Polynomial(p, variables) for p in polys])
end
_variables(polys) = sort!(union(Iterators.flatten(MP.variables.(polys))), rev=true)

Base.length(F::System) = length(F.polys)
Base.getindex(F::System, i) = getindex(F.polys, i)


"""
    nvariables(F::System)

Returns the number of variables of `F`.
"""
nvariables(F::System) = size(exponents(F[1]), 1)

"""

    JacobianConfig(F::Vector{Polynomial{T}}, [x::AbstractVector{S}])

A data structure with which the jacobian of a `Vector` `F` of `Polynomial`s can be
evaluated efficiently. Note that `x` is only used to determine the
output type of `F(x)`.

    JacobianConfig(F::Vector{Polynomial{T}}, [S])

Instead of a vector `x` a type can also be given directly.
"""
mutable struct JacobianConfig{T1, T2}
    polys::Vector{PolyConfig{T1}}
    differences::Matrix{UInt8}
    differences_values::Matrix{T2}
end


function JacobianConfig(f::System{T}, ::AbstractArray{S}) where {T, S}
    JacobianConfig(f, S)
end
JacobianConfig(f::System{T}) where T = JacobianConfig(f, T)
function JacobianConfig(F::System{T}, ::Type{S}) where {T, S}
    diffs, diffs_values, big_lookups, reduced_exponents = differences(F.polys, S)
    polys = broadcast(PolyConfig, F.polys, reduced_exponents, big_lookups, S)

    JacobianConfig(polys, diffs, diffs_values)
end

"""
    config(F::System, x)

Construct a `JacobianConfig` for the evaluation of `F` with values like `x`.
"""
function config(f::System{T}, x::AbstractVector{S}) where {S, T}
    JacobianConfig(f, typeof(one(T) * one(S) + one(T) * one(S)))
end

function differences(F::Vector{<:Polynomial}, ::Type{S}) where {S}
    reduced_exponents = map(F) do f
        convert.(UInt16, max.(f.exponents .- 1, 0))
    end
    differences, big_lookups = computetables(reduced_exponents)
    differences_values = similar(differences, S)

    differences, differences_values, big_lookups, reduced_exponents
end


"""
    evaluate(F, x, cfg::JacobianConfig [, precomputed=false])

Evaluate the system `F` at `x` using the precomputated values in `cfg`.
Note that this is usually signifcant faster than `map(f -> evaluate(f, x), F)`.
The return vector is constructed using `similar(x, T)`.

### Example
```julia
cfg = JacobianConfig(F)
evaluate(F, x, cfg)
```

With `precomputed=true` we rely on the previous intermediate results in `cfg`. Therefore
the result is only correct if you previouls called `evaluate`, or `jacobian` with the same
`x`.
"""
function evaluate(G::System, x::AbstractVector, cfg::JacobianConfig{T}, precomputed=false) where T
    evaluate!(similar(x, T, length(G)), G, x, cfg, precomputed)
end

"""
    evaluate!(u, F, x, cfg::JacobianConfig [, precomputed=false])

Evaluate the system `F` at `x` using the precomputated values in `cfg`
and store the result in `u`.
Note that this is usually signifcant faster than `map!(u, f -> evaluate(f, x), F)`.

### Example
```julia
cfg = JacobianConfig(F)
evaluate!(u, F, x, cfg)
```

With `precomputed=true` we rely on the previous intermediate results in `cfg`. Therefore
the result is only correct if you previouls called `evaluate`, or `jacobian` with the same
`x`.
"""
function evaluate!(u::AbstractVector, G::System, x::AbstractVector, cfg::JacobianConfig, precomputed=false)
    if !precomputed
        fillvalues!(cfg.differences_values, x, cfg.differences)
        for i=1:length(cfg.polys)
            fillreduced_values!(cfg.polys[i], G[i], x, cfg.differences_values)
            u[i] = _evaluate(x, cfg.polys[i])
        end
    else
        for i=1:length(cfg.polys)
            u[i] = _evaluate(x, cfg.polys[i])
        end
    end
    u
end

"""
    jacobian(u, F, x, cfg::JacobianConfig [, precomputed=false])

Evaluate the jacobian of `F` at `x` using the precomputated values in `cfg`. The return
matrix is constructed using `similar(x, T, m, n)`.

### Example
```julia
cfg = JacobianConfig(F)
jacobian(F, x, cfg)
```

With `precomputed=true` we rely on the previous intermediate results in `cfg`. Therefore
the result is only correct if you previouls called `evaluate`, or `jacobian` with the same
`x`.
"""
function jacobian(g::System, x::AbstractVector, cfg::JacobianConfig{T}, precomputed=false) where T
    u = similar(x, T, (length(g), length(x)))
    jacobian!(u, g, x, cfg, precomputed)
    u
end

"""
    jacobian!(u, F, x, cfg::JacobianConfig [, precomputed=false])

Evaluate the jacobian of `F` at `x` using the precomputated values in `cfg`
and store the result in `u`.

### Example
```julia
cfg = JacobianConfig(F)
jacobian!(u, F, x, cfg)
```

With `precomputed=true` we rely on the previous intermediate results in `cfg`. Therefore
the result is only correct if you previouls called `evaluate`, or `jacobian` with the same
`x`.
"""
function jacobian!(u::AbstractMatrix, G::System, x::AbstractVector, cfg::JacobianConfig, precomputed=false)
    if !precomputed
        fillvalues!(cfg.differences_values, x, cfg.differences)
        for i=1:length(G)
            fillreduced_values!(cfg.polys[i], G[i], x, cfg.differences_values)
            gradient_row!(u, x, cfg.polys[i], i)
        end
    else
        for i=1:length(G)
            gradient_row!(u, x, cfg.polys[i], i)
        end
    end
    u
end

"""
    evaluate_and_jacobian!(u, U, F, x, cfg::JacobianConfig)

Evaluate `F` and its Jacobian at `x` using the precomputated values in `cfg`
and store the result in `u` and `U` (Jacobian).

### Example
```julia
evaluate_and_jacobian!(u, U, F, x, config(F, x))
```
"""
function evaluate_and_jacobian!(u::AbstractVector, U::AbstractMatrix, G::System, x::AbstractVector, cfg::JacobianConfig)
    fillvalues!(cfg.differences_values, x, cfg.differences)
    for i=1:length(G)
        fillreduced_values!(cfg.polys[i], G[i], x, cfg.differences_values)
        gradient_row!(U, x, cfg.polys[i], i)
        u[i] = _evaluate(x, cfg.polys[i])
    end
end

function evaluate_and_jacobian(G::System, x::AbstractVector, cfg::JacobianConfig{T}) where T
    u = similar(x, T, length(G))
    U = similar(x, T, (length(G), length(x)))

    evaluate_and_jacobian!(u, U, G, x, cfg)
    u, U
end


"""
    JacobianDiffResult(cfg::GradientConfig)

During the computation of the jacobian ``J_F(x)`` we compute nearly everything we need for the evaluation of
``F(x)``. `JacobianDiffResult` allocates memory to hold both values.
This structure also signals `jacobian!` to store ``F(x)`` and ``J_F(x)``.

### Example

```julia
cfg = JacobianConfig(F, x)
r = JacobianDiffResult(cfg)
jacobian!(r, F, x, cfg)

value(r) == map(f -> f(x), F)
jacobian(r) == jacobian(F, x, cfg)
```

    JacobianDiffResult(value::AbstractVector, jacobian::AbstractMatrix)

Allocate the memory to hold the value and the jacobian by yourself.
"""
mutable struct JacobianDiffResult{T, AV<:AbstractVector{T}, AM<:AbstractMatrix{T}}
    value::AV
    jacobian::AM
end

function JacobianDiffResult(cfg::JacobianConfig{T}) where T
    JacobianDiffResult{T, Vector{T}, Matrix{T}}(
        zeros(T, length(cfg.polys)),
        zeros(T, length(cfg.polys), size(cfg.differences, 1)))
end

@static if VERSION < v"0.7-"
    function JacobianDiffResult(value::AbstractVector{T}, jacobian::AbstractMatrix{T}) where T
        JacobianDiffResult{T, typeof(value), typeof(jacobian)}(value, jacobian)
    end
end

value(r::JacobianDiffResult) = r.value
jacobian(r::JacobianDiffResult) = r.jacobian

"""
    jacobian!(r::JacobianDiffResult, F, x, cfg::JacobianConfig)

Compute ``F(x)`` and the jacobian of `F` at `x` at once using the precomputated values in `cfg`
and store thre result in `r`. This is faster than computing both values separetely.

### Example
```julia
cfg = GradientConfig(g)
r = GradientDiffResult(cfg)
gradient!(r, g, x, cfg)

value(r) == g(x)
gradient(r) == gradient(g, x, cfg)
```
"""
function jacobian!(r::JacobianDiffResult, G::System, x::AbstractVector, cfg::JacobianConfig{T}) where T
    fillvalues!(cfg.differences_values, x, cfg.differences)
    for i=1:length(G)
        fillreduced_values!(cfg.polys[i], G[i], x, cfg.differences_values)
        gradient_row!(r.jacobian, x, cfg.polys[i], i)
        r.value[i] = _evaluate(x, cfg.polys[i])
    end

    r
end
