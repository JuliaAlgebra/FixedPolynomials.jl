using FixedPolySystem
using Base.Test
const FPS = FixedPolySystem

@testset "poly" begin

        p = FPS.Poly([3 1; 1 1; 0 2], [-2.0, 3.0])
        @test string(p) == "-2.0x₁³x₂+3.0x₁x₂x₃²"
        @test p isa FPS.Poly{Float64}
        @test eltype(p) == Float64
        @test FPS.exponents(p) == [3 1; 1 1; 0 2]
        @test FPS.coeffs(p) == [-2.0, 3.0]
        @test FPS.nvariables(p) == 3
        @test FPS.deg(p) == 4

        @test string(FPS.Poly([3 1; 1 1; 0 2], [-2.0, 3.0+2im])) == "-2.0x₁³x₂+(3.0 + 2.0im)x₁x₂x₃²"
        @test string(FPS.Poly([3 1; 1 1; 0 2], [-2.0, 3.0+0im])) == "-2.0x₁³x₂+3.0x₁x₂x₃²"
        @test string(FPS.Poly(collect(1:9),[-1.0])) == "-x₁x₂²x₃³x₄⁴x₅⁵x₆⁶x₇⁷x₈⁸x₉⁹"

        q = FPS.Poly([3; 1; 0], [-2.0])
        @test q([1, 2.0, 3.0]) == -4
        q = FPS.Poly(reshape([1; 1; 2],(3,1)), [3.0])
        @test q([1, 2.0, 3.0]) == 54

        @test p([1, 2.0, 3.0]) == 50

        @test FPS.differentiate(p, 1) == FPS.Poly([2 0; 1 1; 0 2], [-6.0, 3.0])

        @test FPS.gradient(p) == [FPS.differentiate(p, 1), FPS.differentiate(p, 2), FPS.differentiate(p, 3)]

        @test FPS.ishomogenous(p) == true

        @test string(FPS.homogenize(FPS.Poly([1 1; 0 2], [-2.0, 3.0]))) == "-2.0x₀²x₁+3.0x₁x₂²"

        @test FPS.dehomogenize(p) == FPS.Poly([1 1; 0 2], [-2.0, 3.0])


        f = FPS.Poly([2 1 0;0 1 2], [3.0, 2.0, -1.0])
        g = FPS.Poly([2 1 0;0 1 2], [-2.5+2im,-3.0, 4.0])
        @test FPS.weyldot(f,g) == 3.0 * conj(-2.5 + 2im) + 2.0 * (-3.0) / 2 + (-1.0) * 4.0
        @test FPS.weyldot(f, f) == 9.0 + 4.0  / 2 + 1.0
        @test FPS.weylnorm(f)^2 ≈ FPS.weyldot(f,f)
end

@testset "system" begin
        p = FPS.Poly([3 1; 1 1; 0 2], [-2.0, 3.0])

        F = PolySystem([p, p], [:x, :y, :z])
        @test string(F) == "-2.0x³y+3.0xyz²\n-2.0x³y+3.0xyz²\n"
        @test F isa PolySystem{Float64}

        @test polynomials(F) == [p, p]
        @test variables(F) == [:x, :y, :z]
        @test nvariables(F) == 3
        @test ishomogenous(F)
        @test homogenized(F) == false

        x = rand(3)
        @test evaluate(F, x) == [p(x), p(x)]
        @test F(x) == [p(x), p(x)]
        u = zeros(2)
        evaluate!(u, F, x)
        @test u == F(x)

        ishomogenous(F)

        f = FPS.Poly([1 1; 0 2], [-2.0, 3.0])
        hom_f = FPS.homogenize(f)
        F = PolySystem([f])
        hom_F = FPS.homogenize(F)
        @test hom_F == PolySystem([hom_f])
        @test homogenized(hom_F)
        @test dehomogenize(hom_F) == F

        f = FPS.Poly([2 1 0;0 1 2], [3.0, 2.0, -1.0])
        g = FPS.Poly([2 1 0;0 1 2], [-2.5+2im,-3.0, 4.0])
        F = PolySystem([f, f])
        @test length(F) == 2
        @test eltype(F) == typeof(f)
        for p in F
                @test p == f
        end
        G = PolySystem([g, g])
        @test weyldot(F,G) == 2 * weyldot(f,g)
        @test weylnorm(F)^2 ≈ weyldot(F,F)
end
