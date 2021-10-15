import Base: print

Base.show(io::IO, p::Polynomial) = print_poly(io, p, variables(p))

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

# const SUBSCRIPT_TABLE = (0x2080, 0x2081, 0x2082, 0x2083, 0x2084, 0x2085, 0x2086, 0x2087, 0x2088, 0x2089)
# const SUPERSCRIPT_TABLE = (0x2070, 0x00b9, 0x00b2, 0x00b3, 0x2074, 0x2075, 0x2076, 0x2077, 0x2078, 0x2079)

const SUBSCRIPT_TABLE = ('\u2080', '\u2081', '\u2082', '\u2083', '\u2084', '\u2085', '\u2086', '\u2087', '\u2088', '\u2089')
const SUPERSCRIPT_TABLE = ('\u2070', '\u00b9', '\u00b2', '\u00b3', '\u2074', '\u2075', '\u2076', '\u2077', '\u2078', '\u2079')

# const SUBSCRIPT_TABLE = ("₀","₁","₂","₃","₄","₅","₆","₇","₈","₉")
# const SUPERSCRIPT_TABLE = ("⁰","¹","²","³","⁴","⁵","⁶","⁷","⁸","⁹")

unicode_subscript(i::Int) = (SUBSCRIPT_TABLE[i + 1])
unicode_superscript(i::Int) = (SUPERSCRIPT_TABLE[i + 1])

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
