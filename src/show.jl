function Base.show(io::IO, p::Polynomial{T}) where {T}
    vars = variables(p)
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
                print(io, pretty_var(var))
            elseif power > 1
                print(io, pretty_var(var), pretty_power(power))
            end
        end
    end

    if first
        print(io, zero(T))
    end
end

const SUBSCRIPT_TABLE = ('\u2080', '\u2081', '\u2082', '\u2083', '\u2084', '\u2085', '\u2086', '\u2087', '\u2088', '\u2089')
const SUPERSCRIPT_TABLE = ('\u2070', '\u00b9', '\u00b2', '\u00b3', '\u2074', '\u2075', '\u2076', '\u2077', '\u2078', '\u2079')

unicode_subscript(i::Int) = (SUBSCRIPT_TABLE[i + 1])
unicode_superscript(i::Int) = (SUPERSCRIPT_TABLE[i + 1])

function pretty_power(pow::Int)
    io_out = IOBuffer()
    _digits = digits(pow)
    for i in _digits
        print(io_out, unicode_superscript(i))
    end
    return reverse(String(take!(io_out)))
end

function pretty_var(var::String)
    m1 = match(r"([a-zA-Z]+)(?:_*)(\d+)", var)
    m2 = match(r"([a-zA-Z]+)(?:\[)(\d+)(?:\])", var)
    if isnothing(m1) && isnothing(m2)
        return var
    end
    m = isnothing(m1) ? m2 : m1
    io_out = IOBuffer()
    print(io_out, m.captures[1])
    index = parse(Int, m.captures[2])
    _digits = reverse(digits(index))
    for i in _digits
        print(io_out, unicode_subscript(i))
    end
    return String(take!(io_out))
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
