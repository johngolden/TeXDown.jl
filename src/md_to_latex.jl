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

Works for all bullet markers (`*`, `-`, `+`). A single blank line produces a small
gap; each additional blank line adds a full line of space.

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
    lines = split(str, "\n")

    # a top-level bullet item with non-empty content, using any CommonMark marker
    is_bullet_item(line) = occursin(r"^[-*+] +\S", line)

    # separator for a run of `k` blank lines: the first gives the usual small gap,
    # each additional one adds a full line of space
    function separator(k)
        vspace = "\\vspace{0.1cm}"
        if k > 1
            vspace *= "\\vspace{$(k-1)\\baselineskip}"
        end
        return "\n\n`$(vspace)`{=latex}\n\n"
    end

    out = String[]
    i = 1
    n = length(lines)
    while i <= n
        # find runs of blank lines sandwiched between bullet items
        if lines[i] == "" && i > 1 && is_bullet_item(lines[i-1])
            j = i
            while j <= n && lines[j] == ""
                j += 1
            end
            if j <= n && is_bullet_item(lines[j])
                push!(out, separator(j - i))
                i = j
                continue
            end
        end
        push!(out, lines[i])
        i += 1
    end
    return join(out, "\n")
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