
@testset "system" begin
        p = FPS.Poly([3 1; 1 1; 0 2], [-2, 3])
        F = PolySystem([p, p], [:x, :y, :z])
        @test F isa PolySystem{Int64}
        F = convert(PolySystem{Float64}, F)
        @test F isa PolySystem{Float64}
        @test string(F) == "-2.0x³y+3.0xyz²\n-2.0x³y+3.0xyz²\n"

        @test string(substitute(F, :z=>2.0)) == "-2.0x³y+12.0xy\n-2.0x³y+12.0xy\n"
        @test substitute(F, :w=>2.0) == F
        @test nvariables(substitute(F, :z=>2.0)) == 2

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


        Impl.@polyvar x[1:3]
        f = -2.0x[1]^3*x[2]+3.0x[1]*x[2]*x[3]^2
        g = -2.0x[3]^3
        F = PolySystem([f, g])
        @test nvariables(F) == 3
        @test variables(F) == [:x1, :x2, :x3]


        Impl.@polyvar x y
        F = PolySystem([x^2, 3y^3])
        DF = differentiate(F)
        @test DF([2.0, 2.0]) == [4.0 0.0; 0.0 36.0]
end
