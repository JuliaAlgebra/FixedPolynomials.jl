# FixedPolynomials

| **Documentation** | **Build Status** |
|:-----------------:|:----------------:|
| [![][docs-stable-img]][docs-stable-url] | [![Build Status][build-img]][build-url] [![Build Status][winbuild-img]][winbuild-url] |
| [![][docs-latest-img]][docs-latest-url] | [![Codecov branch][codecov-img]][codecov-url] |

[FixedPolynomials.jl](https://github.com/saschatimme/FixedPolynomials.jl) is a library for
*really fast* evaluation of multivariate polynomials.
The latest benchmark results can be found [here](https://github.com/saschatimme/FixedPolynomials.jl/pull/3).

Since `FixedPolynomials` polynomials are optimised for fast evaluation they are not suited
for construction of polynomials.
It is recommended to construct a polynomial with an implementation of
[MultivariatePolynomials.jl](https://github.com/blegat/MultivariatePolynomials.jl), e.g.
[DynamicPolynomials.jl](https://github.com/blegat/DynamicPolynomials.jl), and to
convert it then into a `FixedPolynomials.Polynomial` for further computations.

## Getting started

Install the this package via
```julia
Pkg.add("FixedPolynomials")
```

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

[docs-stable-img]: https://img.shields.io/badge/docs-stable-blue.svg
[docs-latest-img]: https://img.shields.io/badge/docs-latest-blue.svg
[docs-stable-url]: https://saschatimme.github.io/FixedPolynomials.jl/stable
[docs-latest-url]: https://saschatimme.github.io/FixedPolynomials.jl/latest

[build-img]: https://travis-ci.org/saschatimme/FixedPolynomials.jl.svg?branch=master
[build-url]: https://travis-ci.org/saschatimme/FixedPolynomials.jl
[winbuild-img]: https://ci.appveyor.com/api/projects/status/h2yw6aoq480e1etd/branch/master?svg=true
[winbuild-url]: https://ci.appveyor.com/project/saschatimme/fixedpolynomials-jl/branch/master
[codecov-img]: https://codecov.io/gh/saschatimme/FixedPolynomials.jl/branch/master/graph/badge.svg
[codecov-url]: https://codecov.io/gh/saschatimme/FixedPolynomials.jl
