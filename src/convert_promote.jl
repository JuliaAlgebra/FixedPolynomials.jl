function convert(::Type{Polynomial{T}}, p::Polynomial{S}) where {T,S}
    Polynomial{T}(p.exponents, convert(Vector{T}, p.coefficients), p.variables, p.homogenized)
end

function convert(::Type{Polynomial{T}}, p::MP.AbstractPolynomialLike) where {T}
    Polynomial{T}(p)
end

function convert(::Type{Vector{Polynomial{T}}}, ps::Vector{<:MP.AbstractPolynomialLike}) where {T}
    variables = sort!(union(Iterators.flatten(MP.variables.(ps))), rev=true)
    [Polynomial{T}(p, variables) for p in ps]
end

function promote_rule(::Type{Polynomial{T}}, x::Type{Polynomial{S}}) where {T,S}
    Polynomial{promote_type(S,T)}
end
function promote_rule(::Type{Polynomial{T}}, x::Type{S}) where {T,S}
    Polynomial{promote_type(S,T)}
end
