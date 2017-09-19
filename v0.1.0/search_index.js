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
    "text": "Here is an example on how to create a Polynomial with Float64 coefficients:using FixedPolynomials\nimport DynamicPolynomials: @polyvar\n\n@polyvar x y z\n\nf = Polynomial{Float64}(x^2+y^3*z-2x*y)To evaluate f you simply have to pass in a Vector{Float64}x = rand(3)\nf(x) # alternatively evaluate(f, x)note: Note\nThe only defined method is evaluate(f::Polynomial{T}, x::AbstractVector{T}). This is intentional restrictive to avoid any unintended performance penalties.note: Note\nf has then the variable ordering as implied by DynamicPolynomials.variables(x^2+y^3*z-2x*y), i.e. f([1.0, 2.0, 3.0]) will evaluate f with x=1, y=2 and z=3."
},

{
    "location": "reference.html#",
    "page": "Reference",
    "title": "Reference",
    "category": "page",
    "text": ""
},

{
    "location": "reference.html#FixedPolynomials.Polynomial",
    "page": "Reference",
    "title": "FixedPolynomials.Polynomial",
    "category": "Type",
    "text": "Polynomial(p::MultivariatePolynomials.AbstractPolynomial [, variables [, homogenized=false]])\n\nA structure for fast evaluation of multivariate polynomials. The terms are sorted first by total degree, then lexicographically. Polynomial has first class support for homogenous polynomials. This field indicates whether the first variable should be considered as the homogenization variable.\n\nPolynomial{T}(p::MultivariatePolynomials.AbstractPolynomial [, variables [, homogenized=false]])\n\nYou can force a coefficient type T. For optimal performance T should be same type as the input to with which it will be evaluated.\n\nPolynomial(exponents::Matrix{Int}, coefficients::Vector{T}, variables, [, homogenized=false])\n\nYou can also create a polynomial directly. Note that in exponents each column represents the exponent of a term.\n\nExample\n\nPoly([3 1; 1 1; 0 2 ], [-2.0, 3.0], [:x, :y, :z]) == 3.0x^2yz^2 - 2x^3y\n\n\n\n"
},

{
    "location": "reference.html#Types-1",
    "page": "Reference",
    "title": "Types",
    "category": "section",
    "text": "Polynomial"
},

{
    "location": "reference.html#FixedPolynomials.exponents",
    "page": "Reference",
    "title": "FixedPolynomials.exponents",
    "category": "Function",
    "text": "exponents(p::Polynomial)\n\nReturns the exponents matrix of p. Each column represents the exponents of a term of p.\n\n\n\n"
},

{
    "location": "reference.html#FixedPolynomials.coefficients",
    "page": "Reference",
    "title": "FixedPolynomials.coefficients",
    "category": "Function",
    "text": "coefficients(p::Polynomial)\n\nReturns the coefficient vector of p.\n\n\n\n"
},

{
    "location": "reference.html#FixedPolynomials.nterms",
    "page": "Reference",
    "title": "FixedPolynomials.nterms",
    "category": "Function",
    "text": "nterms(p::Polynomial)\n\nReturns the number of terms of p\n\n\n\n"
},

{
    "location": "reference.html#FixedPolynomials.variables",
    "page": "Reference",
    "title": "FixedPolynomials.variables",
    "category": "Function",
    "text": "variables(p::Polynomial)\n\nReturns the variables of p.\n\n\n\n"
},

{
    "location": "reference.html#FixedPolynomials.nvariables",
    "page": "Reference",
    "title": "FixedPolynomials.nvariables",
    "category": "Function",
    "text": "nvariables(p::Polynomial)\n\nReturns the number of variables of p\n\n\n\n"
},

{
    "location": "reference.html#FixedPolynomials.degree",
    "page": "Reference",
    "title": "FixedPolynomials.degree",
    "category": "Function",
    "text": "degree(p::Polynomial)\n\nReturns the (total) degree of p.\n\n\n\n"
},

{
    "location": "reference.html#FixedPolynomials.ishomogenous",
    "page": "Reference",
    "title": "FixedPolynomials.ishomogenous",
    "category": "Function",
    "text": "ishomogenous(p::Polynomial)\n\nChecks whether p is a homogenous polynomial. Note that this is unaffected from the value of homogenized(p).\n\n\n\n"
},

{
    "location": "reference.html#FixedPolynomials.ishomogenized",
    "page": "Reference",
    "title": "FixedPolynomials.ishomogenized",
    "category": "Function",
    "text": "ishomogenized(p::Polynomial)\n\nChecks whether p was homogenized.\n\n\n\n"
},

{
    "location": "reference.html#Accessors-1",
    "page": "Reference",
    "title": "Accessors",
    "category": "section",
    "text": "exponents\ncoefficients\nnterms\nvariables\nnvariables\ndegree\nishomogenous\nishomogenized"
},

{
    "location": "reference.html#FixedPolynomials.evaluate",
    "page": "Reference",
    "title": "FixedPolynomials.evaluate",
    "category": "Function",
    "text": "evaluate(p::Polynomial{T}, x::AbstractVector{T})\n\nEvaluates p at x, i.e. p(x). Polynomial is also callable, i.e. you can also evaluate it via p(x).\n\n\n\n"
},

{
    "location": "reference.html#FixedPolynomials.weyldot",
    "page": "Reference",
    "title": "FixedPolynomials.weyldot",
    "category": "Function",
    "text": "weyldot(f::Polynomial, g::Polynomial)\n\nCompute the Bombieri-Weyl dot product. Note that this is only properly defined if f and g are homogenous.\n\nweyldot(f::Vector{Polynomial}, g::Vector{Polynomial})\n\nCompute the dot product for vectors of polynomials.\n\n\n\n"
},

{
    "location": "reference.html#FixedPolynomials.weylnorm",
    "page": "Reference",
    "title": "FixedPolynomials.weylnorm",
    "category": "Function",
    "text": "weylnorm(f::Polynomial)\n\nCompute the Bombieri-Weyl norm. Note that this is only properly defined if f is homogenous.\n\n\n\n"
},

{
    "location": "reference.html#Evaluation-1",
    "page": "Reference",
    "title": "Evaluation",
    "category": "section",
    "text": "evaluate\nweyldot\nweylnorm"
},

{
    "location": "reference.html#FixedPolynomials.differentiate",
    "page": "Reference",
    "title": "FixedPolynomials.differentiate",
    "category": "Function",
    "text": "differentiate(p::Polynomial, varindex::Int)\n\nDifferentiate p w.r.t the varindexth variable.\n\ndifferentiate(p::Polynomial)\n\nDifferentiate p w.r.t. all variables.\n\n\n\n"
},

{
    "location": "reference.html#FixedPolynomials.∇",
    "page": "Reference",
    "title": "FixedPolynomials.∇",
    "category": "Function",
    "text": "∇(p::Polynomial)\n\nReturns the gradient vector of p. This is the same as differentiate.\n\n\n\n"
},

{
    "location": "reference.html#FixedPolynomials.homogenize",
    "page": "Reference",
    "title": "FixedPolynomials.homogenize",
    "category": "Function",
    "text": "homogenize(p::Polynomial [, variable = :x0])\n\nMakes p homogenous, if ishomogenized(p) is true this is just the identity. The homogenization variable will always be considered as the first variable of the polynomial.\n\n\n\n"
},

{
    "location": "reference.html#FixedPolynomials.dehomogenize",
    "page": "Reference",
    "title": "FixedPolynomials.dehomogenize",
    "category": "Function",
    "text": "dehomogenize(p::Polynomial)\n\nSubstitute 1 as for the first variable p, if ishomogenized(p) is false this is just the identity.\n\n\n\n"
},

{
    "location": "reference.html#Modification-1",
    "page": "Reference",
    "title": "Modification",
    "category": "section",
    "text": "differentiate\n∇\nhomogenize\ndehomogenize"
},

]}
