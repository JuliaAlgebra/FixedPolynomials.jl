"""
    PolySystem(polys[, vars])

Construct a system of polynomials.
"""
struct PolySystem{T<:Number}
    polys::Vector{Poly{T}}
    vars::Vector{Symbol}

    function PolySystem{T}(polys::Vector{Poly{T}}, vars::Vector{Symbol}) where {T<:Number}
        if (length(polys) == 0)
            error("Cannot construct an empty PolySystem")
        end
        nvars = nvariables(polys[1])
        if any(p -> nvariables(p) != nvars, polys)
            error("All polys must have the same number of variables.")
        end
        first_homogenized = homogenized(polys[1])
        if any(p -> homogenized(p) != first_homogenized, polys)
            error("At least one poly is homogenized but not all.")
        end
        new(polys, vars)
    end
end
function PolySystem(polys::Vector{Poly{T}}, vars::Vector{Symbol}) where {T<:Number}
    PolySystem{T}(polys, vars)
end

function PolySystem(polys::Vector{Poly{T}}) where {T<:Number}
    nvars = nvariables(polys[1])
    first_homogenized = homogenized(polys[1])
    if first_homogenized
        vars = [Symbol("x$i") for i=0:nvars-1]
    else
        vars = [Symbol("x$i") for i=1:nvars]
    end
    PolySystem(polys, vars)
end

function ==(P::PolySystem, Q::PolySystem)
    P.vars == Q.vars &&
    P.polys == Q.polys
end

# ITERATOR
start(p::PolySystem) = start(p.polys)
next(p::PolySystem, state) = next(p.polys, state)
done(p::PolySystem, state) = done(p.polys, state)
length(p::PolySystem) = length(p.polys)
eltype(p::PolySystem) = eltype(p.polys)


"""
    variables(P::PolySystem)

The variables of the polynomial system `P`.
"""
variables(P::PolySystem) = P.vars

"""
    nvariables(P::PolySystem)

The number variables of the polynomial system `P`.
"""
nvariables(P::PolySystem) = length(P.vars)

"""
    polynomials(P::PolySystem)

The polynomials of the system `P`.
"""
polynomials(P::PolySystem) = P.polys

"""
    evaluate(P::PolySystem, x)

Evaluate the polynomial system `P` at `x`.
"""
evaluate(P::PolySystem, x) = map(p -> evaluate(p, x), P.polys)
(P::PolySystem)(x) = evaluate(P, x)
"""
    evaluate!(u, P::PolySystem, x)

Evaluate the polynomial system `P` at `x` and store the result in `u`.
"""
evaluate!(u, P::PolySystem, x) = map!(p -> evaluate(p, x), u, P.polys)

"""
    ishomogenous(P::PolySystem)

Checks whether every polynomial of `P` is homogenous.
"""
ishomogenous(P::PolySystem) = all(ishomogenous, P.polys)

"""
    homogenize(P::PolySystem)

Make each polynomial of `P` homogenous.
"""
function homogenize(P::PolySystem; homogenization_variable=:x0)
    if homogenized(P)
        P
    else
        vars = [homogenization_variable; P.vars]
        PolySystem(map(homogenize, P.polys), vars)
    end
end

"""
    homogenized(P::PolySystem)

If the system `P` was homogenized.
"""
homogenized(P::PolySystem) = all(homogenized, P.polys)

"""
    dehomogenize(p::PolySystem)

Dehomogenize each polynomial of `P`.
"""
function dehomogenize(P::PolySystem)
    if homogenized(P)
        vars = P.vars[2:end]
        PolySystem(map(dehomogenize, P.polys), vars)
    else
        P
    end
end


"""
    weyldot(P::PolySystem, Q::PolySystem)

Compute the Bombieri-Weyl dot product between `P` and `Q`.
Assumes that `P` and `Q` are homogenous. See [here](https://en.wikipedia.org/wiki/Bombieri_norm)
for more details.
"""
weyldot(P::PolySystem,Q::PolySystem) = sum(pq -> weyldot(pq[1], pq[2]), zip(P.polys, Q.polys))

"""
    weylnorm(P::PolySystem)

Compute the Bombieri-Weyl norm for `P`. Assumes that `Q` is homogenous.
See [here](https://en.wikipedia.org/wiki/Bombieri_norm) for more details.
"""
weylnorm(P::PolySystem) = √(weyldot(P, P))
