var documenterSearchIndex = {"docs": [

{
    "location": "index.html#",
    "page": "Introduction",
    "title": "Introduction",
    "category": "page",
    "text": ""
},

{
    "location": "index.html#Introduction-1",
    "page": "Introduction",
    "title": "Introduction",
    "category": "section",
    "text": "FixedPolynomials.jl is a library for really fast evaluation of multivariate polynomials. Here are the latest benchmark results.Since FixedPolynomials polynomials are optimised for fast evaluation they are not suited for construction of polynomials. It is recommended to construct a polynomial with an implementation of MultivariatePolynomials.jl, e.g. DynamicPolynomials.jl, and to convert it then into a FixedPolynomials.Polynomial for further computations."
},

{
    "location": "index.html#Tutorial-1",
    "page": "Introduction",
    "title": "Tutorial",
    "category": "section",
    "text": "Here is an example on how to create a Polynomial with Float64 coefficients:using FixedPolynomials\nimport DynamicPolynomials: @polyvar\n\n@polyvar x y z\n\nf = Polynomial{Float64}(x^2+y^3*z-2x*y)To evaluate f you simply have to pass in a Vector{Float64}x = rand(3)\nf(x) # alternatively evaluate(f, x)But this is note the fastest way possible. In order to achieve the best performance we need to precompute some things and also preallocate intermediate storage. For this we have GradientConfig and JacobianConfig. For single polynomial the API is as followscfg = GradientConfig(f) # this can be reused!\nf(x) == evaluate(f, x, cfg)\n# We can also compute the gradient of f at x\nmap(g -> g(x), ∇f) == gradient(f, x, cfg)We also have support for systems of polynomials:cfg = JacobianConfig([f, f]) # this can be reused!\n[f(x), f(x)] == evaluate([f, f] x, cfg)\n# We can also compute the jacobian of [f, f] at x\njacobian(f, x, cfg)Make sure to also check out GradientDiffResult and JacobianDiffResult.note: Note\nf has then the variable ordering as implied by DynamicPolynomials.variables(x^2+y^3*z-2x*y), i.e. f([1.0, 2.0, 3.0]) will evaluate f with x=1, y=2 and z=3."
},

{
    "location": "index.html#Safety-notes-1",
    "page": "Introduction",
    "title": "Safety notes",
    "category": "section",
    "text": "warning: Warning\nFor the evaluation multivariate variant of Horner's method is used. Due to that for polynomials with terms of degree over 43 we cannot guarantee an error of less than 1 ULP."
},

{
    "location": "reference.html#",
    "page": "Polynomial",
    "title": "Polynomial",
    "category": "page",
    "text": ""
},

{
    "location": "reference.html#FixedPolynomials.Polynomial",
    "page": "Polynomial",
    "title": "FixedPolynomials.Polynomial",
    "category": "Type",
    "text": "Polynomial(p::MultivariatePolynomials.AbstractPolynomial [, variables [, homogenized=false]])\n\nA structure for fast evaluation of multivariate polynomials. The terms are sorted first by total degree, then lexicographically. Polynomial has first class support for homogenous polynomials. This field indicates whether the first variable should be considered as the homogenization variable.\n\nPolynomial{T}(p::MultivariatePolynomials.AbstractPolynomial [, variables [, homogenized=false]])\n\nYou can force a coefficient type T. For optimal performance T should be same type as the input to with which it will be evaluated.\n\nPolynomial(exponents::Matrix{Int}, coefficients::Vector{T}, variables, [, homogenized=false])\n\nYou can also create a polynomial directly. Note that in exponents each column represents the exponent of a term.\n\nExample\n\nPoly([3 1; 1 1; 0 2 ], [-2.0, 3.0], [:x, :y, :z]) == 3.0x^2yz^2 - 2x^3y\n\n\n\n"
},

{
    "location": "reference.html#Types-1",
    "page": "Polynomial",
    "title": "Types",
    "category": "section",
    "text": "Polynomial"
},

{
    "location": "reference.html#FixedPolynomials.exponents",
    "page": "Polynomial",
    "title": "FixedPolynomials.exponents",
    "category": "Function",
    "text": "exponents(p::Polynomial)\n\nReturns the exponents matrix of p. Each column represents the exponents of a term of p.\n\n\n\n"
},

{
    "location": "reference.html#FixedPolynomials.coefficients",
    "page": "Polynomial",
    "title": "FixedPolynomials.coefficients",
    "category": "Function",
    "text": "coefficients(p::Polynomial)\n\nReturns the coefficient vector of p.\n\n\n\n"
},

{
    "location": "reference.html#FixedPolynomials.nterms",
    "page": "Polynomial",
    "title": "FixedPolynomials.nterms",
    "category": "Function",
    "text": "nterms(p::Polynomial)\n\nReturns the number of terms of p\n\n\n\n"
},

{
    "location": "reference.html#FixedPolynomials.variables",
    "page": "Polynomial",
    "title": "FixedPolynomials.variables",
    "category": "Function",
    "text": "variables(p::Polynomial)\n\nReturns the variables of p.\n\n\n\n"
},

{
    "location": "reference.html#FixedPolynomials.nvariables",
    "page": "Polynomial",
    "title": "FixedPolynomials.nvariables",
    "category": "Function",
    "text": "nvariables(p::Polynomial)\n\nReturns the number of variables of p\n\n\n\n"
},

{
    "location": "reference.html#FixedPolynomials.degree",
    "page": "Polynomial",
    "title": "FixedPolynomials.degree",
    "category": "Function",
    "text": "degree(p::Polynomial)\n\nReturns the (total) degree of p.\n\n\n\n"
},

{
    "location": "reference.html#FixedPolynomials.ishomogenous",
    "page": "Polynomial",
    "title": "FixedPolynomials.ishomogenous",
    "category": "Function",
    "text": "ishomogenous(p::Polynomial)\n\nChecks whether p is a homogenous polynomial. Note that this is unaffected from the value of homogenized(p).\n\n\n\n"
},

{
    "location": "reference.html#FixedPolynomials.ishomogenized",
    "page": "Polynomial",
    "title": "FixedPolynomials.ishomogenized",
    "category": "Function",
    "text": "ishomogenized(p::Polynomial)\n\nChecks whether p was homogenized.\n\n\n\n"
},

{
    "location": "reference.html#Accessors-1",
    "page": "Polynomial",
    "title": "Accessors",
    "category": "section",
    "text": "exponents\ncoefficients\nnterms\nvariables\nnvariables\ndegree\nishomogenous\nishomogenized"
},

{
    "location": "reference.html#FixedPolynomials.differentiate",
    "page": "Polynomial",
    "title": "FixedPolynomials.differentiate",
    "category": "Function",
    "text": "differentiate(p::Polynomial, varindex::Int)\n\nDifferentiate p w.r.t the varindexth variable.\n\ndifferentiate(p::Polynomial)\n\nDifferentiate p w.r.t. all variables.\n\n\n\n"
},

{
    "location": "reference.html#FixedPolynomials.∇",
    "page": "Polynomial",
    "title": "FixedPolynomials.∇",
    "category": "Function",
    "text": "∇(p::Polynomial)\n\nReturns the gradient vector of p. This is the same as differentiate.\n\n\n\n"
},

{
    "location": "reference.html#FixedPolynomials.homogenize",
    "page": "Polynomial",
    "title": "FixedPolynomials.homogenize",
    "category": "Function",
    "text": "homogenize(p::Polynomial [, variable = :x0])\n\nMakes p homogenous, if ishomogenized(p) is true this is just the identity. The homogenization variable will always be considered as the first variable of the polynomial.\n\n\n\n"
},

{
    "location": "reference.html#FixedPolynomials.dehomogenize",
    "page": "Polynomial",
    "title": "FixedPolynomials.dehomogenize",
    "category": "Function",
    "text": "dehomogenize(p::Polynomial)\n\nSubstitute 1 as for the first variable p, if ishomogenized(p) is false this is just the identity.\n\n\n\n"
},

{
    "location": "reference.html#FixedPolynomials.scale_coefficients!",
    "page": "Polynomial",
    "title": "FixedPolynomials.scale_coefficients!",
    "category": "Function",
    "text": "scale_coefficients!(f::Polynomial, λ)\n\nScale the coefficients of f with the factor λ.\n\n\n\n"
},

{
    "location": "reference.html#Modification-1",
    "page": "Polynomial",
    "title": "Modification",
    "category": "section",
    "text": "differentiate\n∇\nhomogenize\ndehomogenize\nscale_coefficients!"
},

{
    "location": "reference.html#FixedPolynomials.weyldot",
    "page": "Polynomial",
    "title": "FixedPolynomials.weyldot",
    "category": "Function",
    "text": "weyldot(f::Polynomial, g::Polynomial)\n\nCompute the Bombieri-Weyl dot product. Note that this is only properly defined if f and g are homogenous.\n\nweyldot(f::Vector{Polynomial}, g::Vector{Polynomial})\n\nCompute the dot product for vectors of polynomials.\n\n\n\n"
},

{
    "location": "reference.html#FixedPolynomials.weylnorm",
    "page": "Polynomial",
    "title": "FixedPolynomials.weylnorm",
    "category": "Function",
    "text": "weylnorm(f::Polynomial)\n\nCompute the Bombieri-Weyl norm. Note that this is only properly defined if f is homogenous.\n\n\n\n"
},

{
    "location": "reference.html#Misc-1",
    "page": "Polynomial",
    "title": "Misc",
    "category": "section",
    "text": "weyldot\nweylnorm"
},

{
    "location": "performance.html#FixedPolynomials.GradientConfig",
    "page": "Fast Evaluation",
    "title": "FixedPolynomials.GradientConfig",
    "category": "Type",
    "text": "GradientConfig(f::Polynomial{T}, [x::AbstractVector{S}])\n\nA data structure with which the gradient of a Polynomial f can be evaluated efficiently. Note that x is only used to determine the output type of f(x).\n\nGradientConfig(f::Polynomial{T}, [S])\n\nInstead of a vector x a type can also be given directly.\n\n\n\n"
},

{
    "location": "performance.html#FixedPolynomials.JacobianConfig",
    "page": "Fast Evaluation",
    "title": "FixedPolynomials.JacobianConfig",
    "category": "Type",
    "text": "JacobianConfig(F::Vector{Polynomial{T}}, [x::AbstractVector{S}])\n\nA data structure with which the jacobian of a Vector F of Polynomials can be evaluated efficiently. Note that x is only used to determine the output type of F(x).\n\nJacobianConfig(F::Vector{Polynomial{T}}, [S])\n\nInstead of a vector x a type can also be given directly.\n\n\n\n"
},

{
    "location": "performance.html#",
    "page": "Fast Evaluation",
    "title": "Fast Evaluation",
    "category": "page",
    "text": "In order to achieve a fast evaluation we need to precompute some things and also preallocate intermediate storage. For this we have GradientConfig and JacobianConfig:GradientConfig\nJacobianConfig"
},

{
    "location": "performance.html#FixedPolynomials.evaluate",
    "page": "Fast Evaluation",
    "title": "FixedPolynomials.evaluate",
    "category": "Function",
    "text": "evaluate(p::Polynomial{T}, x::AbstractVector{T})\n\nEvaluates p at x, i.e. p(x). Polynomial is also callable, i.e. you can also evaluate it via p(x).\n\n\n\nevaluate(g, x, cfg::GradientConfig)\n\nEvaluate g at x using the precomputated values in cfg. Note that this is usually signifcant faster than evaluate(g, x).\n\nExample\n\ncfg = GradientConfig(g)\nevaluate(g, x, cfg)\n\n\n\nevaluate(F, x, cfg::JacobianConfig)\n\nEvaluate the system F at x using the precomputated values in cfg. Note that this is usually signifcant faster than map(f -> evaluate(f, x), F).\n\nExample\n\ncfg = JacobianConfig(F)\nevaluate(F, x, cfg)\n\n\n\n"
},

{
    "location": "performance.html#FixedPolynomials.evaluate!",
    "page": "Fast Evaluation",
    "title": "FixedPolynomials.evaluate!",
    "category": "Function",
    "text": "evaluate!(u, F, x, cfg::JacobianConfig)\n\nEvaluate the system F at x using the precomputated values in cfg and store the result in u. Note that this is usually signifcant faster than map!(u, f -> evaluate(f, x), F).\n\nExample\n\ncfg = JacobianConfig(F)\nevaluate!(u, F, x, cfg)\n\n\n\n"
},

{
    "location": "performance.html#Evaluation-1",
    "page": "Fast Evaluation",
    "title": "Evaluation",
    "category": "section",
    "text": "evaluate\nevaluate!"
},

{
    "location": "performance.html#FixedPolynomials.gradient",
    "page": "Fast Evaluation",
    "title": "FixedPolynomials.gradient",
    "category": "Function",
    "text": "gradient(g, x, cfg::GradientConfig)\n\nCompute the gradient of g at x using the precomputated values in cfg.\n\nExample\n\ncfg = GradientConfig(g)\ngradient(g, x, cfg)\n\n\n\ngradient(r::GradientDiffResult)\n\nGet the currently stored gradient in r.\n\n\n\n"
},

{
    "location": "performance.html#FixedPolynomials.gradient!",
    "page": "Fast Evaluation",
    "title": "FixedPolynomials.gradient!",
    "category": "Function",
    "text": "gradient!(u, g, x, cfg::GradientConfig)\n\nCompute the gradient of g at x using the precomputated values in cfg and store thre result in u.\n\nExample\n\ncfg = GradientConfig(g)\ngradient(u, g, x, cfg)\n\n\n\ngradient!(r::GradientDiffResult, g, x, cfg::GradientConfig)\n\nCompute g(x) and the gradient of g at x at once using the precomputated values in cfg and store thre result in r. This is faster than calling both values separetely.\n\nExample\n\ncfg = GradientConfig(g)\nr = GradientDiffResult(r)\ngradient!(r, g, x, cfg)\n\nvalue(r) == g(x)\ngradient(r) == gradient(g, x, cfg)\n\n\n\n"
},

{
    "location": "performance.html#FixedPolynomials.jacobian",
    "page": "Fast Evaluation",
    "title": "FixedPolynomials.jacobian",
    "category": "Function",
    "text": "jacobian!(u, F, x, cfg::JacobianConfig)\n\nEvaluate the jacobian of F at x using the precomputated values in cfg.\n\nExample\n\ncfg = JacobianConfig(F)\njacobian(F, x, cfg)\n\n\n\n"
},

{
    "location": "performance.html#FixedPolynomials.jacobian!",
    "page": "Fast Evaluation",
    "title": "FixedPolynomials.jacobian!",
    "category": "Function",
    "text": "jacobian!(u, F, x, cfg::JacobianConfig)\n\nEvaluate the jacobian of F at x using the precomputated values in cfg and store the result in u.\n\nExample\n\ncfg = JacobianConfig(F)\njacobian!(u, F, x, cfg)\n\n\n\njacobian!(r::JacobianDiffResult, F, x, cfg::JacobianConfig)\n\nCompute F(x) and the jacobian of F at x at once using the precomputated values in cfg and store thre result in r. This is faster than computing both values separetely.\n\nExample\n\ncfg = GradientConfig(g)\nr = GradientDiffResult(cfg)\ngradient!(r, g, x, cfg)\n\nvalue(r) == g(x)\ngradient(r) == gradient(g, x, cfg)\n\n\n\n"
},

{
    "location": "performance.html#Derivatives-1",
    "page": "Fast Evaluation",
    "title": "Derivatives",
    "category": "section",
    "text": "FixedPolynomials.gradient\ngradient!\njacobian\njacobian!"
},

{
    "location": "performance.html#FixedPolynomials.GradientDiffResult",
    "page": "Fast Evaluation",
    "title": "FixedPolynomials.GradientDiffResult",
    "category": "Type",
    "text": "GradientDiffResult(cfg::GradientConfig)\n\nDuring the computation of g(x) we compute nearly everything we need for the evaluation of g(x). GradientDiffResult allocates memory to hold both values. This structure also signals gradient! to store g(x) and g(x).\n\nExample\n\ncfg = GradientConfig(g, x)\nr = GradientDiffResult(cfg)\ngradient!(r, g, x, cfg)\n\nvalue(r) == g(x)\ngradient(r) == gradient(g, x, cfg)\n\nGradientDiffResult(grad::AbstractVector)\n\nAllocate the memory to hold the gradient by yourself.\n\n\n\n"
},

{
    "location": "performance.html#FixedPolynomials.JacobianDiffResult",
    "page": "Fast Evaluation",
    "title": "FixedPolynomials.JacobianDiffResult",
    "category": "Type",
    "text": "JacobianDiffResult(cfg::GradientConfig)\n\nDuring the computation of the jacobian J_F(x) we compute nearly everything we need for the evaluation of F(x). JacobianDiffResult allocates memory to hold both values. This structure also signals jacobian! to store F(x) and J_F(x).\n\nExample\n\ncfg = JacobianConfig(F, x)\nr = JacobianDiffResult(cfg)\njacobian!(r, F, x, cfg)\n\nvalue(r) == map(f -> f(x), F)\njacobian(r) == jacobian(F, x, cfg)\n\nJacobianDiffResult(value::AbstractVector, jacobian::AbstractMatrix)\n\nAllocate the memory to hold the value and the jacobian by yourself.\n\n\n\n"
},

{
    "location": "performance.html#FixedPolynomials.value",
    "page": "Fast Evaluation",
    "title": "FixedPolynomials.value",
    "category": "Function",
    "text": "value(r::GradientDiffResult)\n\nGet the currently stored value in r.\n\n\n\n"
},

{
    "location": "performance.html#DiffResults-1",
    "page": "Fast Evaluation",
    "title": "DiffResults",
    "category": "section",
    "text": "GradientDiffResult\nJacobianDiffResult\nvalue"
},

]}
