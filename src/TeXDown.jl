module TeXDown

using CommonMark

include("md_to_latex.jl")
include("fix_commonmark.jl")
include("extensions.jl")
include("clean_latex.jl")
include("templates.jl")
include("main.jl")

export make_latex, todo_list, research_note

end
