using FixedPolySystem
using TypedPolynomials
using BenchmarkTools

function polysystem(x)
    a = 5
    b = 4
    c = 3
    @polyvar sθ cθ z
    f1 = cθ^2 + sθ^2 - (1.0 + 0im)*z^2
    f2 = (a*cθ - b)^2 + (1.0 + 0im) * (a*sθ)^2 - c^2 * z^2
    F = PolySystem([f1, f2])
    @benchmark evaluate($F, $x)
end

x = rand(Complex128, 3)
println("Run PolySystem evaluation benchmark:")
polysystem_benchmark = polysystem(x)
show(STDOUT, MIME"text/plain"(), polysystem_benchmark)
