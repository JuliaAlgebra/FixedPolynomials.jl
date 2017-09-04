@testset "poly" begin
    p = Polynomial([3 1; 1 1; 0 2], [-2.0, 3.0])
    @test string(p) == "-2.0x₁³x₂+3.0x₁x₂x₃²"
    @test p isa Polynomial{Float64}
    @test eltype(p) == Float64
    @test exponents(p) == [3 1; 1 1; 0 2]
    @test coefficients(p) == [-2.0, 3.0]
    @test nvariables(p) == 3
    @test variables(p) == [:x1, :x2, :x3]
    @test degree(p) == 4

    @test (convert(Polynomial{Complex128}, p) isa Polynomial{Complex128})
    q = Polynomial([3 1; 1 1; 0 2], [-2, 3], [:x_1, :x_2, :x_3])
    prom_p, prom_q = promote(p,q)
    @test typeof(prom_p) == typeof(prom_q)
    @test prom_q isa Polynomial{Float64}

    Impl.@polyvar z[1:3]
    f = -2z[1]^3*z[2]+3z[1]*z[2]*z[3]^2
    @test "$(Polynomial(f))" == "-2z₁³z₂+3z₁z₂z₃²"
    @test "$(Polynomial{Float64}(f))" == "-2.0z₁³z₂+3.0z₁z₂z₃²"

    @test string(substitute(Polynomial(f), 2, 2.0)) == "-4.0z₁³+6.0z₁z₃²"
    @test string(substitute(Polynomial(f), 1, 2.0)) == "6.0z₂z₃²-16.0z₂"

    @test "$(Polynomial(z[1]))" == "z₁"
    @test "$(Polynomial(z[1]^2))" == "z₁²"
    @test "$(Polynomial(2z[1]))" == "2z₁"

    q = Polynomial(reshape([3; 1; 0], (3,1)), [-2.0], [:x1, :x2, :x3])
    @test q([1, 2.0, 3.0]) == -4
    q = Polynomial(reshape([1; 1; 2],(3,1)), [3.0], [:x1, :x2, :x3])
    @test q([1, 2.0, 3.0]) == 54
    @test p([1, 2.0, 3.0]) == 50

    @test differentiate(p, 1) == Polynomial([2 0; 1 1; 0 2], [-6.0, 3.0], [:x1, :x2])
    @test differentiate(p) == [differentiate(p, 1), differentiate(p, 2), differentiate(p, 3)]
    Impl.@polyvar y z
    @test size(differentiate(Polynomial(z^2+2+y), 1).exponents) == (2, 1)
    @test size(differentiate(Polynomial(z^2+2+y), 2).exponents) == (2, 1)


    @test ishomogenous(p) == true
    @test string(homogenize(Polynomial([1 1; 0 2], [-2.0, 3.0]))) == "-2.0x₀²x₁+3.0x₁x₂²"
    @test dehomogenize(p) == p
    @test dehomogenize(homogenize(p)) == p

    exponents(homogenize(p))[2:end, :]

    f = Polynomial([2 1 0;0 1 2], [3.0, 2.0, -1.0])
    g = Polynomial([2 1 0;0 1 2], [-2.5+2im,-3.0, 4.0])
    @test weyldot(f,g) == 3.0 * conj(-2.5 + 2im) + 2.0 * (-3.0) / 2 + (-1.0) * 4.0
    @test weyldot(f, f) == 9.0 + 4.0  / 2 + 1.0
    @test weylnorm(f)^2 ≈ weyldot(f,f)
end
