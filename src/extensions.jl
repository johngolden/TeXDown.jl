"""
    add_captions_to_figures(str::String)

Take italic text directly under figures and make it the caption.

# Example

\\caption{}
\\end{figure}
\\textit{A caption for this figure}

becomes

\\caption{A caption for this figure}
\\end{figure}
"""
function add_captions_to_figures(str::String)
    return replace(str, r"\\caption{}\n\\end{figure}\n\\textit{(.*)}\n" => s"\\caption{\1}\n\\end{figure}\n")
end


function add_empty_lines(str::String)
    list = split(str, "\n")

    newline = "\n\n`\\vspace{\\baselineskip}`{=latex}\n\n"

    # Iterate through the list starting from the second element
    for i in 2:length(list)-1
        # Check if the current element is an empty string
        if list[i] == ""
            # Check if the previous element matches the specified patterns
            if (startswith(list[i-1], "* ") && length(list[i-1]) > 2 && startswith(list[i+1], "* "))
                # Replace the current empty string with "PLACEHOLDERSPACE"
                list[i] = newline
            end
        end
    end
    return join(list, "\n")
end