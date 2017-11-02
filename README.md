# FixedPolynomials

| **Documentation** | **Build Status** |
|:-----------------:|:----------------:|
| [![][docs-stable-img]][docs-stable-url] | [![Build Status][build-img]][build-url] [![Build Status][winbuild-img]][winbuild-url] |
| [![][docs-latest-img]][docs-latest-url] | [![Codecov branch][codecov-img]][codecov-url] |

[FixedPolynomials.jl](https://github.com/juliaalgebra/FixedPolynomials.jl) is a library for
*really fast* evaluation of multivariate polynomials.
[Here](https://github.com/juliaalgebra/FixedPolynomials.jl/pull/3) are the latest benchmark results.

Since `FixedPolynomials` polynomials are optimised for fast evaluation they are not suited
for construction of polynomials.
It is recommended to construct a polynomial with an implementation of
[MultivariatePolynomials.jl](https://github.com/juliaalgebra/MultivariatePolynomials.jl), e.g.
[DynamicPolynomials.jl](https://github.com/juliaalgebra/DynamicPolynomials.jl), and to
convert it then into a `FixedPolynomials.Polynomial` for further computations.

## Getting started
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

But this is not the fastest way possible. In order to achieve the best performance we need to precompute some things and also preallocate
intermediate storage. For this we have [`GradientConfig`](@ref) and [`JacobianConfig`](@ref).
For single polynomial the API is as follows
```julia
cfg = GradientConfig(f) # this can be reused!
f(x) == evaluate(f, x, cfg)
# We can also compute the gradient of f at x
map(g -> g(x), ∇f) == gradient(f, x, cfg)
```

We also have support for systems of polynomials:
```julia
cfg = JacobianConfig([f, f]) # this can be reused!
[f(x), f(x)] == evaluate([f, f] x, cfg)
# We can also compute the jacobian of [f, f] at x
jacobian(f, x, cfg)
```

[docs-stable-img]: https://img.shields.io/badge/docs-stable-blue.svg
[docs-latest-img]: https://img.shields.io/badge/docs-latest-blue.svg
[docs-stable-url]: https://juliaalgebra.github.io/FixedPolynomials.jl/stable
[docs-latest-url]: https://juliaalgebra.github.io/FixedPolynomials.jl/latest

[build-img]: https://travis-ci.org/JuliaAlgebra/FixedPolynomials.jl.svg?branch=master
[build-url]: https://travis-ci.org/JuliaAlgebra/FixedPolynomials.jl
[winbuild-img]: https://ci.appveyor.com/api/projects/status/h2yw6aoq480e1etd/branch/master?svg=true
[winbuild-url]: https://ci.appveyor.com/project/juliaalgebra/fixedpolynomials-jl/branch/master
[codecov-img]: https://codecov.io/gh/juliaalgebra/FixedPolynomials.jl/branch/master/graph/badge.svg
[codecov-url]: https://codecov.io/gh/juliaalgebra/FixedPolynomials.jl
