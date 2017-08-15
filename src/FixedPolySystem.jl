module FixedPolySystem
    import TypedPolynomials
    const TP = TypedPolynomials
    import Base: start, next, done, length, eltype, show, ==, convert, promote_rule

    include("poly.jl")
    include("system.jl")
    include("show.jl")
    include("convert_promote.jl")

    export PolySystem,
        nvariables, variables, polynomials,
        evaluate, evaluate!, differentiate,
        ishomogenous, homogenize, homogenized, dehomogenize,
        weyldot, weylnorm

end
