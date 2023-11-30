"""
    make_latex(md_content, template=identity)

Convert the contents of `md_file` into LaTeX.

Optional: include a template function
"""
function make_latex(md_content, template=identity)

    if isfile(md_content)
        md_str = open(md_content, "r") do contents
            read(contents, String)
        end
    else
        md_str = md_content
    end

    # format the markdown string before parsing to latex
    md_str = add_newlines_to_equations(md_str)
    md_str = add_empty_lines(md_str)

    # convert to latex
    tex_str = md_to_latex(md_str)

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

    # add preamble and ending
    tex_str = template(tex_str)

    if isfile(md_content)
        create_and_open_tex_file(md_content, tex_str)
    else
        return tex_str
    end
end

function create_and_open_tex_file(md_filename::String, content::String)
    if endswith(md_filename, ".md")
        tex_filename = replace(md_filename, ".md" => ".tex")

        open(tex_filename, "w") do file
            write(file, content)
        end

        run(`open $(tex_filename)`)  # For macOS

        return true
    else
        println("The provided filename does not end with '.md'")
        return false
    end
end

"""
    make_pdf(md_file, template)

Convert the contents of `md_file` to a LaTeX file according to `template` and compile to
pdf, deleting the auxiliary files and opening the pdf after successful compilation.

The pdf is stored in the same location as `md_file`.
"""
function make_pdf(md_file, template)
    make_tex(md_file, template)
    filename = md_file[1:end-3]
    cd(dirname(md_file))
    run(`pdflatex $(filename).tex`)
    run(`rm $(filename).log`)
    run(`rm $(filename).aux`)
    run(`rm $(filename).out`)
    run(`rm $(filename).tex`)
    run(`open $(filename).pdf`)
end