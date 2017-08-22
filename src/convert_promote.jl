function convert(::Type{Poly{T}}, p::Poly{S}) where {T,S}
    Poly{T}(p.exponents, convert(Vector{T}, p.coeffs), p.homogenized)
end
function convert(::Type{PolySystem{T}}, P::PolySystem{S}) where {T,S}
    polys = map(p -> convert(Poly{T}, p), P.polys)
    PolySystem{T}(polys, P.vars)
end

promote_rule(::Type{Poly{T}}, x::Type{Poly{S}}) where {T,S} = Poly{promote_type(S,T)}
promote_rule(::Type{Poly{T}}, x::Type{S}) where {T,S} = Poly{promote_type(S,T)}
promote_rule(::Type{PolySystem{T}}, x::Type{PolySystem{S}}) where {T,S} = PolySystem{promote_type(S,T)}
promote_rule(::Type{PolySystem{T}}, x::Type{S}) where {T,S} = PolySystem{promote_type(S,T)}
