function convert(::Type{Polynomial{T}}, p::Polynomial{S}) where {T,S}
    Polynomial{T}(p.exponents, convert(Vector{T}, p.coefficients), p.variables, p.homogenized)
end
function promote_rule(::Type{Polynomial{T}}, x::Type{Polynomial{S}}) where {T,S}
    Polynomial{promote_type(S,T)}
end
function promote_rule(::Type{Polynomial{T}}, x::Type{S}) where {T,S}
    Polynomial{promote_type(S,T)}
end
