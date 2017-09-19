module FixedPolynomials
    import MultivariatePolynomials
    const MP = MultivariatePolynomials
    import Base: ==, convert, promote_rule

    abstract type AbstractPolySystem{T} end
    export AbstractPolySystem

    include("poly.jl")
    include("show.jl")
    include("convert_promote.jl")
end