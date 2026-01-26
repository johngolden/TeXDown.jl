using Test
using TeXDown

# test_helpers.jl is included from runtests.jl

@testset "clean_latex.jl" begin

    @testset "replace_par_with_newlines" begin
        @testset "basic behavior" begin
            @test TeXDown.replace_par_with_newlines("text\\par\nmore") == "text\n\nmore"
        end

        @testset "edge cases" begin
            # No \par - unchanged
            @test TeXDown.replace_par_with_newlines("no par here") == "no par here"

            # Multiple \par
            input = "a\\par\nb\\par\nc"
            result = TeXDown.replace_par_with_newlines(input)
            @test result == "a\n\nb\n\nc"

            # Empty string
            @test TeXDown.replace_par_with_newlines("") == ""
        end
    end

    @testset "remove_environment_padding" begin
        @testset "basic behavior" begin
            # Removes double newline before \begin
            input = "text\n\n\\begin{itemize}"
            result = TeXDown.remove_environment_padding(input)
            @test result == "text\n\\begin{itemize}"

            # Removes double newline before \end
            input = "\\item x\n\n\\end{itemize}"
            result = TeXDown.remove_environment_padding(input)
            @test result == "\\item x\n\\end{itemize}"
        end

        @testset "edge cases" begin
            # Single newline - unchanged
            input = "text\n\\begin{itemize}"
            @test TeXDown.remove_environment_padding(input) == input

            # Empty string
            @test TeXDown.remove_environment_padding("") == ""

            # Both \begin and \end padding
            input = "text\n\n\\begin{itemize}\n\\item x\n\n\\end{itemize}"
            result = TeXDown.remove_environment_padding(input)
            @test result == "text\n\\begin{itemize}\n\\item x\n\\end{itemize}"
        end
    end

    @testset "remove_list_newlines" begin
        @testset "basic behavior" begin
            # Collapses \n\item\n to \n\item (needs leading newline for regex)
            input = "\n\\item\nx"
            result = TeXDown.remove_list_newlines(input)
            @test contains(result, "\\item x")
        end

        @testset "edge cases" begin
            # No list items - unchanged
            input = "no list here"
            @test TeXDown.remove_list_newlines(input) == input

            # Multiple items
            input = "\n\\item\na\n\\item\nb"
            result = TeXDown.remove_list_newlines(input)
            @test contains(result, "\\item a")
            @test contains(result, "\\item b")

            # Empty string
            @test TeXDown.remove_list_newlines("") == ""

            # \item already on same line - unchanged
            input = "\\item already same line"
            @test TeXDown.remove_list_newlines(input) == input
        end
    end

    @testset "add_newlines_before_subsections" begin
        @testset "basic behavior" begin
            # Adds extra newline before \subsection
            input = "text\n\\subsection{Title}"
            result = TeXDown.add_newlines_before_subsections(input)
            @test result == "text\n\n\\subsection{Title}"

            # Works for \subsubsection too
            input = "text\n\\subsubsection{Title}"
            result = TeXDown.add_newlines_before_subsections(input)
            @test result == "text\n\n\\subsubsection{Title}"
        end

        @testset "edge cases" begin
            # No subsections - unchanged
            input = "\\section{Title}\ntext"
            @test TeXDown.add_newlines_before_subsections(input) == input

            # Already has double newline - adds another (potential issue)
            input = "text\n\n\\subsection{Title}"
            result = TeXDown.add_newlines_before_subsections(input)
            @test result == "text\n\n\n\\subsection{Title}"

            # Empty string
            @test TeXDown.add_newlines_before_subsections("") == ""
        end
    end

    @testset "remove_double_empty_lines" begin
        @testset "basic behavior" begin
            @test TeXDown.remove_double_empty_lines("a\n\n\nb") == "a\n\nb"
        end

        @testset "edge cases" begin
            # Single empty line - unchanged
            @test TeXDown.remove_double_empty_lines("a\n\nb") == "a\n\nb"

            # Multiple triple newlines - all reduced
            input = "a\n\n\nb\n\n\nc"
            result = TeXDown.remove_double_empty_lines(input)
            @test result == "a\n\nb\n\nc"

            # Four newlines - reduces to three (needs multiple passes)
            input = "a\n\n\n\nb"
            result = TeXDown.remove_double_empty_lines(input)
            @test result == "a\n\n\nb"  # Only one pass in the function

            # Empty string
            @test TeXDown.remove_double_empty_lines("") == ""
        end
    end

    @testset "add_indents" begin
        @testset "basic behavior" begin
            # Adds indentation inside environments
            input = heredoc("""
                \\begin{itemize}
                \\item x
                \\end{itemize}
                """)
            result = TeXDown.add_indents(input)
            @test contains(result, "    \\item x")
        end

        @testset "edge cases" begin
            # Nested environments - increases indent
            input = heredoc("""
                \\begin{itemize}
                \\item outer
                \\begin{itemize}
                \\item inner
                \\end{itemize}
                \\end{itemize}
                """)
            result = TeXDown.add_indents(input)
            @test contains(result, "        \\item inner")  # 8 spaces

            # No environments - adds trailing newline only
            input = "plain text"
            result = TeXDown.add_indents(input)
            @test result == "plain text\n"

            # Empty string - just newline
            @test TeXDown.add_indents("") == "\n"

            # Mismatched begin/end - counter can go negative
            # The function will still run but may produce odd results
            input = heredoc("""
                \\end{itemize}
                text
                \\begin{itemize}
                """)
            result = TeXDown.add_indents(input)
            @test contains(result, "text")  # Still processes
        end
    end

    @testset "check_for_inline_begins" begin
        @testset "basic behavior" begin
            # Should warn about inline \begin
            input = "text \\begin{equation}"
            # This should trigger a warning - we test it doesn't error
            @test_logs (:warn,) TeXDown.check_for_inline_begins("\n" * input)
        end

        @testset "edge cases" begin
            # Proper \begin on new line - no warning
            input = "text\n\\begin{equation}"
            @test_logs TeXDown.check_for_inline_begins(input)

            # Empty string - no warning
            @test_logs TeXDown.check_for_inline_begins("")
        end
    end
end
