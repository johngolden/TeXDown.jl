"""
    add_newlines_to_equations(str::String)

Adds newlines before and after equation environments `\$\$...\$\$`.
These newlines are required by CommonMark.jl but may be missing in the original markdown.
"""
function add_newlines_to_equations(str::String)
    return replace(str, r"([ ]*)\$\$([^$]*)\n([ ]*)\$\$" => s"\n\1$$\2\n\3$$\n")
end

"""
    preserve_blank_lines(str::String)

Translate runs of blank lines in the Markdown into equivalent vertical space in the
output, instead of letting `CommonMark` collapse them.

Rules:
* a single blank line between bullet items (`*`, `-`, or `+`) splits them into two
  lists separated by a small gap
* each blank line beyond the first, between any two top-level blocks, adds a full
  line of space
* blank lines inside fenced code blocks, at the start or end of the file, or next
  to indented content are left untouched

# Example
```
* a
* b

* c
* d
```
will now render as two separate lists with a blank line between them.
"""
function preserve_blank_lines(str::String)
    lines = split(str, "\n")

    # a top-level bullet item with non-empty content, using any CommonMark marker
    is_bullet_item(line) = occursin(r"^[-*+] +\S", line)
    is_fence(line) = occursin(r"^(```|~~~)", line)
    is_top_level(line) = occursin(r"^\S", line)

    # separator for a run of `k` blank lines: bullet items get the usual small gap,
    # and each blank line beyond the first adds a full line of space
    function separator(k, between_bullets)
        vspace = between_bullets ? "\\vspace{0.1cm}" : ""
        if k > 1
            vspace *= "\\vspace{$(k-1)\\baselineskip}"
        end
        return "\n\n`$(vspace)`{=latex}\n\n"
    end

    out = String[]
    i = 1
    n = length(lines)
    in_code_fence = false
    while i <= n
        line = lines[i]
        if is_fence(line)
            in_code_fence = !in_code_fence
        end
        if in_code_fence || line != "" || i == 1
            push!(out, line)
            i += 1
            continue
        end

        # at the start of a blank-line run; find where it ends
        j = i
        while j <= n && lines[j] == ""
            j += 1
        end
        k = j - i

        prev = lines[i-1]
        next = j <= n ? lines[j] : nothing
        if next !== nothing && is_top_level(prev) && is_top_level(next)
            between_bullets = is_bullet_item(prev) && is_bullet_item(next)
            if between_bullets || k > 1
                push!(out, separator(k, between_bullets))
                i = j
                continue
            end
        end

        # leave the run untouched
        for _ in 1:k
            push!(out, "")
        end
        i = j
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