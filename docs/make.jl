using Documenter, FixedPolynomials

makedocs(
    format = :html,
    sitename = "FixedPolynomials.jl",
    pages = [
        "Introduction" => "index.md",
        "Reference" => "reference.md",
        ]
)

deploydocs(
    repo   = "github.com/saschatimme/FixedPolynomials.jl.git",
    target = "build",
    julia = "0.6",
    osname = "linux",
    deps   = nothing,
    make   = nothing
)
