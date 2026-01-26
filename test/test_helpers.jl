"""
Shared utilities for TeXDown tests.
"""

"""
    heredoc(str)

Strip leading indentation from multiline strings for cleaner test formatting.
Removes the common leading whitespace from all lines.
"""
function heredoc(str::String)
    lines = split(str, "\n")

    # Remove first line if empty (common with triple-quoted strings)
    if !isempty(lines) && isempty(strip(lines[1]))
        lines = lines[2:end]
    end

    # Remove last line if empty
    if !isempty(lines) && isempty(strip(lines[end]))
        lines = lines[1:end-1]
    end

    # Find minimum indentation (ignoring empty lines)
    min_indent = typemax(Int)
    for line in lines
        if !isempty(line)
            indent = length(line) - length(lstrip(line))
            min_indent = min(min_indent, indent)
        end
    end

    if min_indent == typemax(Int)
        min_indent = 0
    end

    # Strip the common indentation
    stripped = [length(line) >= min_indent ? line[min_indent+1:end] : line for line in lines]
    return join(stripped, "\n")
end

"""
    normalize_whitespace(str)

Normalize whitespace for comparison: trim lines, collapse multiple blank lines.
"""
function normalize_whitespace(str::String)
    lines = split(str, "\n")
    # Trim trailing whitespace from each line
    lines = [rstrip(line) for line in lines]
    # Join and collapse multiple blank lines
    result = join(lines, "\n")
    while contains(result, "\n\n\n")
        result = replace(result, "\n\n\n" => "\n\n")
    end
    return strip(result)
end
