@testset "PolynomialEvaluationArray" begin
    Impl.@polyvar x y

    f = Polynomial{Complex128}(x^2*y+4y^3+x+1)
    g = Polynomial{Complex128}(x+y+x^5-2x)

    F = PolynomialEvaluationArray([f g; g f])

    u = zeros(Complex128, 2, 2)
    w = rand(Complex128, 2)

    evaluate!(u, F, w)
    @test u[1, 1] ≈ evaluate(f, w)
    @test u[2, 2] ≈ evaluate(f, w)
    @test u[2, 1] ≈ evaluate(g, w)
    @test u[1, 2] ≈ evaluate(g, w)

    w = rand(Complex128, 2)
    fillvalues!(F, w)
    @test unsafe_evaluate(F, 2, 2) ≈ evaluate(f, w)
    @test unsafe_evaluate(F, 1, 2) ≈ evaluate(g, w)
    @test unsafe_evaluate(F, 3) ≈ evaluate(g, w)

    G = PolynomialEvaluationArray([f g])
    w = rand(Complex128, 2)
    fillvalues!(G, w)
    @test unsafe_evaluate(G, 1) ≈ evaluate(f, w)
    @test unsafe_evaluate(G, 2) ≈ evaluate(g, w)
end
