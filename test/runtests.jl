using FixedPolySystem
using Base.Test
const FPS = FixedPolySystem

# import TypedPolynomials
# Impl = TypedPolynomials
# include("poly_test.jl")
# include("system_test.jl")

import DynamicPolynomials
Impl = DynamicPolynomials
include("poly_test.jl")
include("system_test.jl")
