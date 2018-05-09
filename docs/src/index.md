# Introduction

[FixedPolynomials.jl](https://github.com/saschatimme/FixedPolynomials.jl) is a library for
*really fast* evaluation of multivariate polynomials.
[Here](https://github.com/saschatimme/FixedPolynomials.jl/pull/3) are the latest benchmark results.

Since `FixedPolynomials` polynomials are optimised for fast evaluation they are not suited
for construction of polynomials.
It is recommended to construct a polynomial with an implementation of
[MultivariatePolynomials.jl](https://github.com/blegat/MultivariatePolynomials.jl), e.g.
[DynamicPolynomials.jl](https://github.com/blegat/DynamicPolynomials.jl), and to
convert it then into a `FixedPolynomials.Polynomial` for further computations.

## Tutorial
Here is an example on how to create a `Polynomial` with `Float64` coefficients:
```julia
using FixedPolynomials
import DynamicPolynomials: @polyvar

@polyvar x y z

f = Polynomial{Float64}(x^2+y^3*z-2x*y)
```
To evaluate `f` you simply have to pass in a `Vector{Float64}`
```julia
x = rand(3)
f(x) # alternatively evaluate(f, x)
```

But this is note the fastest way possible. In order to achieve the best performance we need to precompute some things and also preallocate
intermediate storage. For this we have [`GradientConfig`](@ref) and [`JacobianConfig`](@ref).
For single polynomial the API is as follows
```julia
cfg = config(f, x) # this can be reused!
f(x) == evaluate(f, x, cfg)
# We can also compute the gradient of f at x
map(g -> g(x), ∇f) == gradient(f, x, cfg)
```

We also have support for systems of polynomials:
```julia
F = System([f, g])
cfg = config(F, x) # this can be reused!
[f(x), f(x)] == evaluate([f, f] x, cfg)
# We can also compute the jacobian of [f, f] at x
jacobian(f, x, cfg)
```

Make sure to also check out [`GradientDiffResult`](@ref) and [`JacobianDiffResult`](@ref).


!!! note
    `f` has then the variable ordering as implied by `DynamicPolynomials.variables(x^2+y^3*z-2x*y)`, i.e.
    `f([1.0, 2.0, 3.0])` will evaluate `f` with `x=1`, `y=2` and `z=3`.


## Safety notes

!!! warning
    The current implementation is not numerically stable in the sense that
    for polynomials with terms of degree over 43 we cannot guarantee
    an error of less than 1 [ULP](https://en.wikipedia.org/wiki/Unit_in_the_last_place).
