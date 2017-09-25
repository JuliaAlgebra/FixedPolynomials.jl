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
```
using FixedPolynomials
import DynamicPolynomials: @polyvar

@polyvar x y z

f = Polynomial{Float64}(x^2+y^3*z-2x*y)
```
To evaluate `f` you simply have to pass in a `Vector{Float64}`
```
x = rand(3)
f(x) # alternatively evaluate(f, x)
```
!!! note

    The only defined method is `evaluate(f::Polynomial{T}, x::AbstractVector{T})`.
    This is intentional restrictive to avoid any unintended performance penalties.



!!! note
    `f` has then the variable ordering as implied by `DynamicPolynomials.variables(x^2+y^3*z-2x*y)`, i.e.
    `f([1.0, 2.0, 3.0])` will evaluate `f` with `x=1`, `y=2` and `z=3`.


## Safety notes

!!! warning
    For the evaluation multivariate variant of [Horner's method](https://en.wikipedia.org/wiki/Horner%27s_method)
    is used. Due to that for polynomials with terms of degree over 43 we cannot guarantee
    an error of less than 1 [ULP](https://en.wikipedia.org/wiki/Unit_in_the_last_place).
