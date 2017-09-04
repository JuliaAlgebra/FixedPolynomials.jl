using FixedPolynomials
using Base.Test
# import TypedPolynomials
# Impl = TypedPolynomials
# include("poly_test.jl")
# include("system_test.jl")

import DynamicPolynomials
Impl = DynamicPolynomials
include("poly_test.jl")
include("system_test.jl")


Impl.@polyvar x y


f = x + y
import MultivariatePolynomials
MP = MultivariatePolynomials
Symbol.(MP.variables(f))

Symbol(:x) == :x


function test1(xs, x)
    map(y -> y + x, xs)
end

function test2(xs, x)
    map(+, xs, Base.Iterators.repeated(x))
end

import BenchmarkTools: @benchmark
