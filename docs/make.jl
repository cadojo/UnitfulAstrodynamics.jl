using Documenter, Astrodynamics

makedocs(modules=[Astrodynamics],
    format=Documenter.HTML(),
    sitename="Astrodynamics.jl",
    pages=[
        "Home" => "index.md",
        "Overview" => Any[
            "About" => "Overview/about.md",
            "Usage" => "Overview/usage.md"
        ],
        "`TwoBody`" => Any[
            "Data Structures and Types" => "TwoBody/types.md",
            "Functions" => "TwoBody/functions.md"
        ],
        "`NBody`" => Any[
            "Data Structures and Types" => "NBody/types.md",
            "Functions" => "NBody/functions.md"
        ],
        "`Propagators`" => Any[
            "Data Structures and Types" => "Propagators/types.md",
            "Functions" => "Propagators/functions.md"
        ],
        "`Plots`" => Any[
            "Functions" => "Plots/functions.md"
        ],
        "Common `AbstractTypes`" => Any[
            "Types" => "AbstractTypes/types.md"
        ]
    ]
)

deploydocs(
    root   = "docs/",
    target = "build",
    repo   = "github.com/cadojo/Astrodynamics.jl",
    branch = "gh-pages",
    deps   = nothing | <Function>,
    make   = nothing | <Function>,
    devbranch = "main",
    devurl = "dev",
    versions = ["stable" => "v^", "v#.#", devurl => devurl],
    push_preview    = false,
    repo_previews   = repo,
    branch_previews = branch,
)

