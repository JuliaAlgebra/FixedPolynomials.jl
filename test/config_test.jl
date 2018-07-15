@testset "Config" begin
    Impl.@polyvar x y z

    f = Polynomial{Float64}(x^2+3y+z*x+y^2+12*x^7*z^5)
    g = Polynomial{Float64}(4*y*x^2-3z+z*x^4+y+y^2-y*x)

    ∇f = [differentiate(f, i) for i=1:3]
    ∇g = [differentiate(g, i) for i=1:3]

    w = rand(3)
    u = zeros(3)

    cfg = config(f, w)
    @test cfg isa GradientConfig
    @test f(w) ≈ evaluate(f, w, cfg)
    @test [p(w) for p in ∇f] ≈ FixedPolynomials.gradient(f, w, cfg)
    @test [p(w) for p in ∇f] ≈ FixedPolynomials.gradient!(u, f, w, cfg)
    @test [p(w) for p in ∇f] ≈ u

    @test_throws BoundsError FixedPolynomials.gradient(f, rand(2), cfg)
    @test_throws BoundsError FixedPolynomials.gradient!(u, f, rand(2), cfg)
    @test_throws BoundsError FixedPolynomials.gradient!(u[1:2], f, w, cfg)

    wc = rand(ComplexF64, 3)
    uc = zeros(ComplexF64, 3)
    cfg = config(f, wc)
    @test cfg isa GradientConfig
    @test f(wc) ≈ evaluate(f, wc, cfg)
    @test [p(wc) for p in ∇f] ≈ FixedPolynomials.gradient(f, wc, cfg)
    @test [p(wc) for p in ∇f] ≈ FixedPolynomials.gradient!(uc, f, wc, cfg)
    @test [p(wc) for p in ∇f] ≈ uc

    cfg = config(f, w)
    @test f(w) ≈ evaluate(f, w, cfg)
    @test [p(w) for p in ∇f] ≈ FixedPolynomials.gradient(f, w, cfg, true)
    @test [p(w) for p in ∇f] ≈ FixedPolynomials.gradient(f, w, cfg)
    @test f(w) ≈ evaluate(f, w, cfg, true)

    u = zeros(3)
    @test f(w) ≈ evaluate(f, w, cfg)
    @test [p(w) for p in ∇f] ≈ FixedPolynomials.gradient!(u, f, w, cfg, true)


    r = GradientDiffResult(cfg)

    FixedPolynomials.gradient!(r, f, w, cfg)
    @test f(w) ≈ value(r)
    @test [p(w) for p in ∇f] ≈ FixedPolynomials.gradient(r)

    v = zeros(4)
    r = GradientDiffResult((@view v[1:3]))
    FixedPolynomials.gradient!(r, f, w, cfg)
    @test f(w) ≈ value(r)
    @test [p(w) for p in ∇f] ≈ FixedPolynomials.gradient(r)


    @test_throws MethodError GradientConfig([f, f], w)
end
