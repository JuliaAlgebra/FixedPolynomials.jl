@testset "poly" begin
    p = FPS.Poly([3 1; 1 1; 0 2], [-2.0, 3.0])
    @test string(p) == "-2.0x₁³x₂+3.0x₁x₂x₃²"
    @test p isa FPS.Poly{Float64}
    @test eltype(p) == Float64
    @test FPS.exponents(p) == [3 1; 1 1; 0 2]
    @test FPS.coeffs(p) == [-2.0, 3.0]
    @test FPS.nvariables(p) == 3
    @test FPS.deg(p) == 4

    @test (convert(FPS.Poly{Complex128}, p) isa FPS.Poly{Complex128})
    q = FPS.Poly([3 1; 1 1; 0 2], [-2, 3])
    prom_p, prom_q = promote(p,q)
    @test typeof(prom_p) == typeof(prom_q)
    @test prom_q isa FPS.Poly{Float64}

    Impl.@polyvar x[1:3]
    f = -2.0x[1]^3*x[2]+3.0x[1]*x[2]*x[3]^2
    @test "$(FPS.Poly(f))" == "-2.0x₁³x₂+3.0x₁x₂x₃²"
    @test "$(FPS.Poly(x[1]))" == "x₁"
    @test "$(FPS.Poly(x[1]^2))" == "x₁²"
    @test "$(FPS.Poly(2x[1]))" == "2x₁"

    @test string(FPS.Poly([3 1; 1 1; 0 2], [-2.0, 3.0+2im])) == "-2.0x₁³x₂+(3.0 + 2.0im)x₁x₂x₃²"
    @test string(FPS.Poly([3 1; 1 1; 0 2], [-2.0, 3.0+0im])) == "-2.0x₁³x₂+3.0x₁x₂x₃²"
    @test string(FPS.Poly(collect(1:9),[-1.0])) == "-x₁x₂²x₃³x₄⁴x₅⁵x₆⁶x₇⁷x₈⁸x₉⁹"

    q = FPS.Poly([3; 1; 0], [-2.0])
    @test q([1, 2.0, 3.0]) == -4
    q = FPS.Poly(reshape([1; 1; 2],(3,1)), [3.0])
    @test q([1, 2.0, 3.0]) == 54

    @test p([1, 2.0, 3.0]) == 50

    @test FPS.differentiate(p, 1) == FPS.Poly([2 0; 1 1; 0 2], [-6.0, 3.0])

    @test FPS.differentiate(p) == [FPS.differentiate(p, 1), FPS.differentiate(p, 2), FPS.differentiate(p, 3)]

    @test FPS.ishomogenous(p) == true

    @test string(FPS.homogenize(FPS.Poly([1 1; 0 2], [-2.0, 3.0]))) == "-2.0x₀²x₁+3.0x₁x₂²"

    @test FPS.dehomogenize(p) == FPS.Poly([1 1; 0 2], [-2.0, 3.0])


    f = FPS.Poly([2 1 0;0 1 2], [3.0, 2.0, -1.0])
    g = FPS.Poly([2 1 0;0 1 2], [-2.5+2im,-3.0, 4.0])
    @test FPS.weyldot(f,g) == 3.0 * conj(-2.5 + 2im) + 2.0 * (-3.0) / 2 + (-1.0) * 4.0
    @test FPS.weyldot(f, f) == 9.0 + 4.0  / 2 + 1.0
    @test FPS.weylnorm(f)^2 ≈ FPS.weyldot(f,f)
end
