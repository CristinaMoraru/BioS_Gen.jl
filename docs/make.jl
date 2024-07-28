using BioS_Gen
using Documenter

DocMeta.setdocmeta!(BioS_Gen, :DocTestSetup, :(using BioS_Gen); recursive=true)

makedocs(;
    modules=[BioS_Gen],
    authors="Cristina Moraru",
    sitename="BioS_Gen.jl",
    format=Documenter.HTML(;
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)
