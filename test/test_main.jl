using Test
using TeXDown

# test_helpers.jl is included from runtests.jl

@testset "main.jl" begin

    @testset "make_tex" begin
        @testset "basic behavior - pipeline integration" begin
            # Simple markdown through full pipeline
            input = heredoc("""
                # Title

                Some text here.

                ## Section

                * item 1
                * item 2
                """)
            result = make_tex(input)

            # Check pre-processing happened (md converted)
            @test contains(result, "\\section{Title}")
            @test contains(result, "\\subsection{Section}")
            @test contains(result, "\\begin{itemize}")
            @test contains(result, "\\item")

            # Check cleaning happened (indentation added)
            @test contains(result, "    \\item")  # indented
        end

        @testset "edge cases" begin
            # Empty string
            result = make_tex("")
            @test result == "\n"  # Just newline from add_indents

            # Whitespace only
            result = make_tex("   \n   ")
            @test !contains(result, "section")

            # Equations get processed
            input = heredoc("""
                Text before
                \$\$
                x = 1
                \$\$
                Text after
                """)
            result = make_tex(input)
            @test contains(result, "equation")

            # Quotation marks get fixed
            input = "He said \"hello\""
            result = make_tex(input)
            @test contains(result, "``hello''")

            # Figure width gets fixed
            # This requires a figure to be in the input which comes from CommonMark
            # We'll test the pipeline produces valid output with an image
            input = "![](test.png)"
            result = make_tex(input)
            @test contains(result, "includegraphics")
            @test contains(result, "width=0.8\\textwidth")
        end

        @testset "with template" begin
            input = heredoc("""
                # My Note

                Content here.
                """)

            # Test with research_note template
            result = make_tex(input, research_note; save=false)
            @test contains(result, "\\documentclass")
            @test contains(result, "\\begin{document}")
            @test contains(result, "\\end{document}")
            @test contains(result, "Content here")
        end
    end

    @testset "pipeline preserves structure" begin
        # Test that nested structures come through correctly
        input = heredoc("""
            # Title

            ## Section 1

            Paragraph with *emphasis* and **bold**.

            * outer
              * inner item 1
              * inner item 2
            * back to outer

            ## Section 2

            Inline math: \$E=mc^2\$
            """)
        result = make_tex(input)

        # Headers preserved
        @test contains(result, "\\section{Title}")
        @test contains(result, "\\subsection{Section 1}")
        @test contains(result, "\\subsection{Section 2}")

        # Formatting preserved
        @test contains(result, "\\textit{emphasis}")
        @test contains(result, "\\textbf{bold}")

        # Nested lists preserved
        @test count("\\begin{itemize}", result) >= 2

        # Math preserved
        @test contains(result, "E=mc^2")
    end
end
