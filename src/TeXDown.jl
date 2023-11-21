module TeXDown

using CommonMark

include("md_to_latex.jl")
include("fix_commonmark.jl")
include("extensions.jl")
include("clean_latex.jl")
include("templates.jl")
include("main.jl")

end
