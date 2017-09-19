# FixedPolynomials
[![Build Status](https://travis-ci.org/saschatimme/FixedPolynomials.jl.svg?branch=master)](https://travis-ci.org/saschatimme/FixedPolynomials.jl)
[![codecov](https://codecov.io/gh/saschatimme/FixedPolynomials.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/saschatimme/FixedPolynomials.jl)

[FixedPolynomials.jl](https://github.com/saschatimme/FixedPolynomials.jl) is a library for
*really fast* evaluation of multivariate polynomials.
[Here](https://github.com/saschatimme/FixedPolynomials.jl/pull/3) are the latest benchmark results.

Since `FixedPolynomials` polynomials are optimised for fast evaluation they are not suited
for construction of polynomials.
It is recommended to construct a polynomial with an implementation of
[MultivariatePolynomials.jl](https://github.com/blegat/MultivariatePolynomials.jl), e.g.
[DynamicPolynomials.jl](https://github.com/blegat/DynamicPolynomials.jl), and to
convert it then into a `FixedPolynomials.Polynomial` for further computations.

## Getting started

Install the this package via
```
Pkg.add("FixedPolynomials")
```

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
