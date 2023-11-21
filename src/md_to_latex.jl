"""
    add_newlines_to_equations(str::String)

Adds newlines before and after equation environments `\$\$...\$\$`.
These newlines are required by CommonMark.jl but may be missing in the original markdown.
"""
function add_newlines_to_equations(str::String)
    return replace(str, r"([ ]*)\$\$([^$]*)\n([ ]*)\$\$" => s"\n\1$$\2\n\3$$\n")
end

"""
    md_to_latex(str::String)

Parses a string in Markdown into a LaTeX formatted string.
"""
function md_to_latex(str::String)
    parser = Parser()
    enable!(parser, DollarMathRule())
    enable!(parser, TableRule())
    ast = parser(str)
    return latex(ast)
end