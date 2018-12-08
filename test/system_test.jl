using LinearAlgebra

@testset "System" begin
    Impl.@polyvar x y z

    f = Polynomial{Float64}(x^2+3y+z*x+y^2+12*x^7*z^5)
    g = Polynomial{Float64}(4*y*x^2-3z+z*x^4+y+y^2-y*x)

    ∇f = [differentiate(f, i) for i=1:3]
    ∇g = [differentiate(g, i) for i=1:3]

    w = rand(3)
    u = zeros(3)

    @test_throws MethodError JacobianConfig(f, w)

    u = zeros(2)
    F = System([f, g])
    cfg = config(F, w)
    @test [f(w), g(w)] ≈ evaluate(F, w, cfg)
    @test [f(w), g(w)] ≈ evaluate!(u, F, w, cfg)
    @test [f(w), g(w)] ≈ u

    @test !isempty(sprint, show, F)
    @test !isempty(sprint(show, cfg))
    @test_throws BoundsError evaluate(F, rand(2), cfg)

    u = zeros(2)
    cfg = JacobianConfig(F, w)
    jacobian(F, w, cfg)
    @test [f(w), g(w)] ≈ evaluate(F, w, cfg, true)
    @test [f(w), g(w)] ≈ evaluate!(u, F, w, cfg, true)
    @test [f(w), g(w)] ≈ u

    cfg2 = deepcopy(cfg)
    @test cfg2 !== cfg

    U = zeros(2, 3)

    DF = [∇f[1](w) ∇f[2](w) ∇f[3](w); ∇g[1](w) ∇g[2](w) ∇g[3](w)]
    evaluate(F, w, cfg)
    @test DF ≈ jacobian(F, w, cfg, true)
    @test DF ≈ jacobian!(U, F, w, cfg, true)
    @test DF ≈ U
    @test_throws BoundsError jacobian(F, rand(2), cfg)
    @test_throws BoundsError jacobian!(U[1:end-1,:],F, w, cfg)
    @test_throws BoundsError jacobian!(U[:,1:end-1],F, w, cfg)


    r = JacobianDiffResult(cfg)
    jacobian!(r, F, w, cfg)
    @test DF ≈ jacobian(r)
    @test [f(w), g(w)] ≈ value(r)

    u, U = evaluate_and_jacobian(F, w, cfg)
    @test U ≈ jacobian(r)
    @test u ≈ value(r)

    v = zeros(3)
    V = zeros(3, 3)

    r = JacobianDiffResult((@view v[1:2]), (@view V[1:2, :]))
    jacobian!(r, F, w, cfg)
    @test DF ≈ jacobian(r)
    @test [f(w), g(w)] ≈ value(r)
end
