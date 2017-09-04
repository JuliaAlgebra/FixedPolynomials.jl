# Introduction

[FixedPolynomials.jl](https://github.com/saschatimme/FixedPolynomials.jl) is an library for *fast* evaluation of multivariate polynomials.
It is recommended to design the user facing API with
[MultivariatePolynomials.jl](https://github.com/blegat/MultivariatePolynomials.jl) and to
convert the input polynomials into `FixedPolynomials` polynomials for further computations.

## Tutorial
Here is a simple example on how to create a `Polynomial` using [DynamicPolynomials.jl](https://github.com/blegat/DynamicPolynomials.jl):
```
using FixedPolynomials
import DynamicPolynomials: @polyvar

@polyvar x y z

f = Polynomial(x^2+y^3*z-2x*y)
```
