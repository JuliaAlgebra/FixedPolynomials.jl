using BenchmarkTools
using FixedPolynomials
import DynamicPolynomials: @polyvar

@polyvar x y
f1 = x + y + 1
f2 = (x + 1)^4 + y
f3 = 50x^3+83x^2*y+24x*y^2+y^3+392x^2+414x*y+50y^2-28x+59y-100
f4 = x+x^2+y+x*y^3+x^4*y^2+3x^3*y+10*x*y+10x^2*y+10x*y^2+15x^2*y^2+10x^3*y^2

w = rand(2)

function make(f, w)
    p = Polynomial{Float64}(f)
    result = @benchmark evaluate($p, $w)
    println(STDOUT, f)
    show(STDOUT, MIME"text/plain"(), result)
    println("\n")
end

println("FixedPolynomials", "\n")
make(f1, w)
make(f2, w)
make(f3, w)
make(f4, w)
