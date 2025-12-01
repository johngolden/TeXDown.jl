"""
    make_tex(md_content)

Turn `md_content` -- either a Markdown file or string -- into LaTeX without a preamble.
"""
function make_tex(md_content; save=false)
    if endswith(md_content, ".md")
        if !isfile(md_content)
            error("File not found: $md_content")
        end
        md_str = open(md_content, "r") do contents
            read(contents, String)
        end
    else
        md_str = md_content
    end

    # format the markdown string before parsing to latex
    md_str = add_newlines_to_equations(md_str)
    md_str = add_empty_lines_to_lists(md_str)

    # convert to latex
    tex_str = md_to_tex(md_str)

    # fix CommonMark.jl bugs/shortcomings
    tex_str = fix_list_formatting(tex_str)
    tex_str = fix_figure_width(tex_str)
    tex_str = fix_quotation_marks(tex_str)

    # add extensions
    tex_str = add_captions_to_figures(tex_str)

    # make the latex file look nice
    tex_str = replace_par_with_newlines(tex_str)
    tex_str = remove_environment_padding(tex_str)
    tex_str = remove_list_newlines(tex_str)
    tex_str = add_newlines_before_subsections(tex_str)
    tex_str = remove_double_empty_lines(tex_str)
    tex_str = add_indents(tex_str)

    if save
        save_tex(md_content, tex_str)
    else
        return tex_str
    end
end

"""
    make_tex(md_content, template)

Convert the contents of `md_content` into LaTeX with `template`.
"""
function make_tex(md_content, template; save=true)
    tex_str = make_tex(md_content)
    tex_str = template(tex_str)

    if save
        save_tex(md_content, tex_str)
    else
        return tex_str
    end
end

"""
    save_tex(md_content, tex_str)

Save the TeX string to a file.

Only works if `md_content` is Markdown file.
"""
function save_tex(md_content, tex_str)
    if isfile(md_content)
        tex_filename = replace(md_content, ".md" => ".tex")

        open(tex_filename, "w") do file
            write(file, tex_str)
        end
    else
        return tex_str
    end
end

"""
    make_pdf(md_file, template)

Convert the contents of `md_file` to a LaTeX file according to `template` and compile to
pdf, deleting the auxiliary files and opening the pdf after successful compilation.

The pdf is stored in the same location as `md_file`.
"""
function make_pdf(md_file, template)
    # Validate input
    if !isfile(md_file)
        error("File not found: $md_file")
    end

    make_tex(md_file, template)

    # Get absolute path and split into directory and filename
    abs_path = abspath(md_file)
    dir = dirname(abs_path)
    filename, _ = splitext(basename(abs_path))
    tex_file = filename * ".tex"
    pdf_file = filename * ".pdf"

    # Run pdflatex from the file's directory to handle paths with spaces
    cd(dir) do
        try
            # Run twice for references, use nonstopmode to avoid hanging on errors
            run(`pdflatex -interaction=nonstopmode $tex_file`)
            run(`pdflatex -interaction=nonstopmode $tex_file`)
        catch e
            @warn "pdflatex failed: $e"
            rethrow(e)
        end
        delete_aux_files(filename)
        run(`open $pdf_file`)
    end
end

"""
    delete_aux_files(filename)

Delete auxiliary `pdflatex` files.
"""
function delete_aux_files(filename)
    for ext in ["log", "aux", "out", "tex"]
        filepath = "$filename.$ext"
        if isfile(filepath)
            rm(filepath)
        end
    end
end
