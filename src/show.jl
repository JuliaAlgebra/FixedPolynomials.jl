import Base: print

function Base.show(io::IO, p::Polynomial)
    # if p.homogenized
    #     vars = ["x$i" for i=0:nvariables(p)-1]
    # else
    #     vars = ["x$i" for i=1:nvariables(p)]
    # end
    print_poly(io, p, variables(p))
end

function Base.show(io::IO, P::System{T}) where T
    print(io, "System{$T}:")
    for p in P.polys
        print(io, "\n")
        print_poly(io, p, variables(p))
    end
end

#helpers

function print_poly(io::IO, p::Polynomial{T}, vars) where T
    first = true
    exps = exponents(p)
    cfs = coefficients(p)

    m, n = size(exps)

    for i=1:n
        exp = exps[:, i]
        coeff = cfs[i]

        if (!first && show_plus(coeff))
            print(io, "+")
        end
        first = false

        if (coeff != 1 && coeff != -1) || exp == zeros(Int, m)
            show_coeff(io, coeff)
        elseif coeff == -1
            print(io, "-")
        end

        for (var, power) in zip(vars, exp)
            if power == 1
                print(io, "$(pretty_var(var))")
            elseif power > 1
                print(io, "$(pretty_var(var))$(pretty_power(power))")
            end
        end
    end

    if first
        print(io, zero(T))
    end
end

function unicode_subscript(i)
    if i == 0
        "\u2080"
    elseif i == 1
        "\u2081"
    elseif i == 2
        "\u2082"
    elseif i == 3
        "\u2083"
    elseif i == 4
        "\u2084"
    elseif i == 5
        "\u2085"
    elseif i == 6
        "\u2086"
    elseif i == 7
        "\u2087"
    elseif i == 8
        "\u2088"
    elseif i == 9
        "\u2089"
    end
end


function unicode_superscript(i)
    if i == 0
        "\u2070"
    elseif i == 1
        "\u00B9"
    elseif i == 2
        "\u00B2"
    elseif i == 3
        "\u00B3"
    elseif i == 4
        "\u2074"
    elseif i == 5
        "\u2075"
    elseif i == 6
        "\u2076"
    elseif i == 7
        "\u2077"
    elseif i == 8
        "\u2078"
    elseif i == 9
        "\u2079"
    end
end

pretty_power(pow::Int) = join(map(unicode_superscript, reverse(digits(pow))))

function pretty_var(var::String)
    m = match(r"([a-zA-Z]+)(?:_*)(\d+)", var)
    if m === nothing
        var
    else
        base = string(m.captures[1])
        index = parse(Int, m.captures[2])
        base * join(map(unicode_subscript, reverse(digits(index))))
    end
end
pretty_var(var) = pretty_var(string(var))

# helpers
show_plus(x::Real) = x >= 0
show_plus(x::Complex) = x != -1

show_coeff(io::IO, x::Real) = print(io, x)
function show_coeff(io::IO, x::Complex)
    if imag(x) == 0.0
        print(io, convert(Float64, x))
    else
        print(io, "($(x))")
    end
end
