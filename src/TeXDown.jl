module TeXDown

using CommonMark

include("md_to_latex.jl")
include("fix_commonmark.jl")
include("extensions.jl")
include("clean_latex.jl")

include("templates.jl")
export todo_list, research_note

include("main.jl")
export make_tex, make_pdf

end
