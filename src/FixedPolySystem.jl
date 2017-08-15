module FixedPolySystem

import Base: start, next, done, length, eltype, show, ==
# package code goes here
    include("poly.jl")
    include("system.jl")
    include("show.jl")

    export PolySystem,
        nvariables, variables, polynomials,
        evaluate, evaluate!,
        ishomogenous, homogenize, homogenized, dehomogenize,
        weyldot, weylnorm

end # module
