"""
    replace_par_with_newlines(str::String)

Replace the `\\par` formatting with newlines.
"""
function replace_par_with_newlines(str::String)
    return replace(str, "\\par\n" => "\n\n")
end


"""
    remove_environment_padding(str::String)

Delete newline padding around `\\begin{}...\\end{}` environments.
"""
function remove_environment_padding(str::String)
    str = replace(str, "\n\n\\begin" => "\n\\begin")
    return replace(str, "\n\n\\end" => "\n\\end")
end


"""
    remove_list_newlines(str::String)

Remove unnecessary newlines around `\\item`.

# Example

\\item
x

becomes 

\\item x
"""
function remove_list_newlines(str::String)
    return replace(str, r"\n[\s]*\\item\n" => "\n\\item ")
end


"""
    add_newlines_before_subsections(str::String)

Adds newlines before `\\sub(sub)section` commands.
"""
function add_newlines_before_subsections(str::String)
    return replace(str, "\n\\sub" => "\n\n\\sub")
end


"""
    remove_double_empty_lines(str::String)

Eliminates consecutive empty lines, reducing them to a single empty line.
"""
function remove_double_empty_lines(str::String)
    return replace(str, "\n\n\n" => "\n\n")
end


"""
    check_for_inline_begins(str::String)

Find "\\begin"s with non-empty strings preceding them on a newline.
"""
function check_for_inline_begins(str::String)
    # finds lines with some non-space characters followed by "\\begin{"
    pattern = r"\n\S.*\\begin{"

    matches = eachmatch(pattern, str)
    lines = [match.match for match in matches]

    if !isempty(lines)
        @warn "Inline \\begin{} found, will mess up indentation:\n" * join(lines, "\n")
    end
end


"""
    add_indents(str::String)

Add indentation level inside each \\begin{}...\\end{}.

Note: assumes each "\\begin" starts on a new line without preceding characters.
"""
function add_indents(str::String)
    # warn if there are \begins with preceding characters
    check_for_inline_begins(str)

    indent_counter = 0
    lines = split(str,"\n")
    txt = ""
    for i in eachindex(lines)
        line = lines[i]
        if length(line) > 4 && line[1:5] == "\\end{"
            indent_counter -= 1
        end
        indent = join(["    " for _ in 1:indent_counter])
        txt *= indent*line*"\n"
        if length(line) > 6 && line[1:7] == "\\begin{"
            indent_counter += 1
        end
    end
    return txt
end