@testset "Config" begin
    Impl.@polyvar x y z

    f = Polynomial{Float64}(x^2+3y+z*x+y^2+12*x^7*z^5)
    g = Polynomial{Float64}(4*y*x^2-3z+z*x^4+y+y^2-y*x)

    ∇f = [differentiate(f, i) for i=1:3]
    ∇g = [differentiate(g, i) for i=1:3]

    w = rand(3)
    u = zeros(3)

    cfg = GradientConfig(f, w)
    @test f(w) ≈ evaluate(f, w, cfg)
    @test [p(w) for p in ∇f] ≈ gradient(f, w, cfg)
    @test [p(w) for p in ∇f] ≈ gradient!(u, f, w, cfg)
    @test [p(w) for p in ∇f] ≈ u

    cfg = GradientConfig(f, Complex128)
    wc = rand(Complex128, 3)
    uc = zeros(Complex128, 3)
    @test f(wc) ≈ evaluate(f, wc, cfg)
    @test [p(wc) for p in ∇f] ≈ gradient(f, wc, cfg)
    @test [p(wc) for p in ∇f] ≈ gradient!(uc, f, wc, cfg)
    @test [p(wc) for p in ∇f] ≈ uc

    cfg = GradientConfig(f)
    @test f(w) ≈ evaluate(f, w, cfg)
    @test [p(w) for p in ∇f] ≈ gradient(f, w, cfg)
    @test [p(w) for p in ∇f] ≈ gradient!(u, f, w, cfg)
    @test [p(w) for p in ∇f] ≈ u

    cfg2 = deepcopy(cfg)
    @test cfg2 !== cfg

    r = GradientDiffResult(cfg)

    gradient!(r, f, w, cfg)
    @test f(w) ≈ value(r)
    @test [p(w) for p in ∇f] ≈ gradient(r)

    v = zeros(4)
    r = GradientDiffResult((@view v[1:3]))
    gradient!(r, f, w, cfg)
    @test f(w) ≈ value(r)
    @test [p(w) for p in ∇f] ≈ gradient(r)


    @test_throws MethodError GradientConfig([f, f], w)
    @test_throws MethodError JacobianConfig(f, w)

    u = zeros(2)
    cfg = JacobianConfig([f, g], w)
    @test [f(w), g(w)] ≈ evaluate([f, g], w, cfg)
    @test [f(w), g(w)] ≈ evaluate!(u, [f, g], w, cfg)
    @test [f(w), g(w)] ≈ u

    cfg2 = deepcopy(cfg)
    @test cfg2 !== cfg

    U = zeros(2, 3)
    DF = vcat(RowVector([p(w) for p in ∇f]), [p(w) for p in ∇g] |> RowVector)
    @test DF ≈ jacobian([f, g], w, cfg)
    @test DF ≈ jacobian!(U, [f, g], w, cfg)
    @test DF ≈ U

    r = JacobianDiffResult(cfg)
    jacobian!(r, [f, g], w, cfg)
    @test DF ≈ jacobian(r)
    @test [f(w), g(w)] ≈ value(r)


    v = zeros(3)
    V = zeros(3, 3)

    r = JacobianDiffResult((@view v[1:2]), (@view V[1:2, :]))
    jacobian!(r, [f, g], w, cfg)
    @test DF ≈ jacobian(r)
    @test [f(w), g(w)] ≈ value(r)
end
