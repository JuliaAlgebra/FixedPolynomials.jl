"""
    PolySystem(polys[, vars])

Construct a system of polynomials.
"""
struct PolySystem{T<:Number} <: AbstractPolySystem{T}
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
	if length(polys) == 0
		error("Cannot construct an empty PolySystem")
	end
    nvars = nvariables(polys[1])
    first_homogenized = homogenized(polys[1])
    if first_homogenized
        vars = [Symbol("x$i") for i=0:nvars-1]
    else
        vars = [Symbol("x$i") for i=1:nvars]
    end
    PolySystem(polys, vars)
end

function PolySystem(polys::Vector{P}) where {P<:MP.AbstractPolynomialLike}
	if length(polys) == 0
		error("Cannot construct an empty PolySystem")
	end
	vars = union(Iterators.flatten(MP.variables.(polys)))
	PolySystem(map(p -> Poly(p, vars), polys), Symbol.(vars))
end

coefftype(::PolySystem{T}) where T = T

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
    degrees(P::PolySystem)

The (total) degrees of the polynomials of the system `P`.
"""
degrees(P::PolySystem) = deg.(P.polys)


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
    substitute(P::PolySystem, var=>x)

Substitute a variable with a constant value.

## Example

    substitute([x^2-y, y^2-x], :x=>2.0) == [-y+4.0, y^2-2.0]
"""
function substitute(P::PolySystem, pair::Pair{Symbol,<:Number})
    indexofvar = findfirst(variables(P), first(pair))
    if indexofvar == 0
        return P
    end
    polys = map(p -> substitute(p, indexofvar, last(pair)), P.polys)

    PolySystem(polys, [P.vars[1:indexofvar-1]; P.vars[indexofvar+1:end]])
 end

 """
     removepoly(P::PolySystem, i)

 Remove the `i`-th polynomial from the system. This assume all variables still ocurr in the
 new system.
 """
removepoly(P::PolySystem, i::Int) = PolySystem([P.polys[1:i-1]; P.polys[i+1:end]], P.vars)

"""
    differentiate(P::PolySystem)

Differentiates the polynomial system `P` and returns an evaluation function `x -> J_P(x)`
where `J_P` is the differentiate of `P`.
"""
function differentiate(P::PolySystem{T}) where {T<:Number}
	m = length(P)
	n = nvariables(P)
	polys = polynomials(P)
	jacobian = [differentiate(polys[i], j) for i=1:m,j=1:n]

	x -> map(p -> p(x), jacobian)
end

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
