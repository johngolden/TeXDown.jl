"""
    add_newlines_to_equations(str::String)

Adds newlines before and after equation environments `\$\$...\$\$`.
These newlines are required by CommonMark.jl but may be missing in the original markdown.
"""
function add_newlines_to_equations(str::String)
    return replace(str, r"([ ]*)\$\$([^$]*)\n([ ]*)\$\$" => s"\n\1$$\2\n\3$$\n")
end

"""
    add_empty_lines_to_lists(str::String)

Take blank lines in between list elements and force the creation of two separate lists.

By default, `CommonMark` removes blank lines and will combine lists.

# Example
```
* a
* b

* c
* d
```
will now render as two separate lists with a blank line between them.
"""
function add_empty_lines_to_lists(str::String)
    list = split(str, "\n")

    newline = "\n\n`\\vspace{0.1cm}`{=latex}\n\n"

    for i in 2:length(list)-1
        # Check if the current element is an empty string
        if list[i] == ""
            # Check if the previous element matches the specified patterns
            if (startswith(list[i-1], "* ") && length(list[i-1]) > 2 && startswith(list[i+1], "* "))
                # Replace the current empty string with newline
                list[i] = newline
            end
        end
    end
    return join(list, "\n")
end

"""
    md_to_latex(str::String)

Parses a string in Markdown into a LaTeX formatted string.
"""
function md_to_tex(str::String)
    parser = Parser()
    enable!(parser, DollarMathRule())
    enable!(parser, TableRule())
    enable!(parser, RawContentRule())
    ast = parser(str)
    return latex(ast)
end