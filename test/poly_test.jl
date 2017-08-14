@testset "poly" begin





end

p = FixedPolySystem.Poly([3 1; 1 1; 0 2], [-2.0, 3.0])

@test p isa FixedPolySystem.Poly{Float64}
