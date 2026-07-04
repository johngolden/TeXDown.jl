using Test
using TeXDown

# test_helpers.jl is included from runtests.jl

@testset "md_to_latex.jl" begin

    @testset "add_newlines_to_equations" begin
        @testset "basic behavior" begin
            # The regex expects format: $$...\n$$ (newline before closing $$)
            # Adds newlines around equation blocks
            input = "text\$\$x=1\n\$\$more"
            result = TeXDown.add_newlines_to_equations(input)
            @test contains(result, "\n\$\$")
            @test contains(result, "\$\$\n")
        end

        @testset "edge cases" begin
            # No equations - unchanged
            @test TeXDown.add_newlines_to_equations("no equations here") == "no equations here"

            # Already has newlines - still works
            input = "text\n\$\$x=1\n\$\$\nmore"
            result = TeXDown.add_newlines_to_equations(input)
            @test contains(result, "\$\$")

            # Inline math ($...$) should be unchanged
            input = "inline \$x\$ math"
            @test TeXDown.add_newlines_to_equations(input) == input

            # Multi-line equation (matrix)
            input = heredoc("""
                text
                \$\$
                A = \\begin{pmatrix}
                    1 & 2 \\\\
                    3 & 4
                \\end{pmatrix}
                \$\$
                more
                """)
            result = TeXDown.add_newlines_to_equations(input)
            @test contains(result, "pmatrix")
        end
    end

    @testset "preserve_blank_lines" begin
        @testset "basic behavior" begin
            # Single blank line between list items creates visual break
            input = heredoc("""
                * a
                * b

                * c
                * d
                """)
            result = TeXDown.preserve_blank_lines(input)
            @test contains(result, "\\vspace{0.1cm}")
        end

        @testset "bullet marker parity" begin
            # Dash and plus markers get the same split treatment as stars
            for marker in ["-", "+"]
                input = heredoc("""
                    $marker a
                    $marker b

                    $marker c
                    $marker d
                    """)
                result = TeXDown.preserve_blank_lines(input)
                @test contains(result, "\\vspace{0.1cm}")
            end

            # Mixed markers across the blank line also split
            input = heredoc("""
                * a
                * b

                - c
                - d
                """)
            result = TeXDown.preserve_blank_lines(input)
            @test contains(result, "\\vspace{0.1cm}")

            # Checkbox items split too
            input = heredoc("""
                - [ ] a
                - [x] b

                - [ ] c
                """)
            result = TeXDown.preserve_blank_lines(input)
            @test contains(result, "\\vspace{0.1cm}")
        end

        @testset "multiple blank lines" begin
            # Two blank lines add one extra line of space
            input = "* a\n* b\n\n\n* c\n* d\n"
            result = TeXDown.preserve_blank_lines(input)
            @test contains(result, "\\vspace{0.1cm}\\vspace{1\\baselineskip}")

            # Three blank lines add two extra lines of space
            input = "* a\n* b\n\n\n\n* c\n* d\n"
            result = TeXDown.preserve_blank_lines(input)
            @test contains(result, "\\vspace{0.1cm}\\vspace{2\\baselineskip}")

            # A single blank line keeps the original small gap
            input = "* a\n\n* b\n"
            result = TeXDown.preserve_blank_lines(input)
            @test contains(result, "\\vspace{0.1cm}")
            @test !contains(result, "baselineskip")

            # Multiple blanks between a paragraph and a list also add space
            input = "some text\n\n\n* a\n* b\n"
            result = TeXDown.preserve_blank_lines(input)
            @test contains(result, "\\vspace{1\\baselineskip}")
            @test !contains(result, "0.1cm")  # small gap is bullet-to-bullet only

            # ... and between two paragraphs
            input = "para one\n\n\n\npara two\n"
            result = TeXDown.preserve_blank_lines(input)
            @test contains(result, "\\vspace{2\\baselineskip}")
        end

        @testset "untouched regions" begin
            # A single blank between non-bullet blocks stays a plain separator
            input = "some text\n\npara two\n"
            @test TeXDown.preserve_blank_lines(input) == input

            # Blank runs inside fenced code blocks are untouched
            input = "```\ncode\n\n\nmore code\n```\n"
            @test TeXDown.preserve_blank_lines(input) == input

            # Blank runs next to indented content are untouched
            input = "* a\n  * a1\n\n\n  * a2\n"
            @test TeXDown.preserve_blank_lines(input) == input

            # Leading and trailing blank runs are untouched
            input = "\n\n* a\n\n\n"
            @test TeXDown.preserve_blank_lines(input) == input
        end

        @testset "edge cases" begin
            # No blank lines - unchanged
            input = heredoc("""
                * a
                * b
                * c
                """)
            result = TeXDown.preserve_blank_lines(input)
            @test !contains(result, "\\vspace")

            # Single item list - unchanged
            input = "* single item"
            @test TeXDown.preserve_blank_lines(input) == input

            # Empty input
            @test TeXDown.preserve_blank_lines("") == ""

            # Numbered list - does NOT add vspace (only works for bullet lists)
            input = heredoc("""
                1. a
                2. b

                3. c
                """)
            result = TeXDown.preserve_blank_lines(input)
            @test !contains(result, "\\vspace")
        end
    end

    @testset "md_to_tex" begin
        @testset "basic behavior" begin
            # Simple paragraph
            result = TeXDown.md_to_tex("Hello world")
            @test contains(result, "Hello world")

            # Header becomes section
            result = TeXDown.md_to_tex("# Title")
            @test contains(result, "\\section{Title}")

            # H2 becomes subsection
            result = TeXDown.md_to_tex("## Subtitle")
            @test contains(result, "\\subsection{Subtitle}")
        end

        @testset "edge cases" begin
            # Empty string
            result = TeXDown.md_to_tex("")
            @test result == ""

            # Inline math
            result = TeXDown.md_to_tex("Equation: \$E=mc^2\$")
            @test contains(result, "E=mc^2")

            # Display math
            input = heredoc("""
                Before

                \$\$
                x = 1
                \$\$

                After
                """)
            result = TeXDown.md_to_tex(input)
            @test contains(result, "equation")

            # Code block
            result = TeXDown.md_to_tex("`code`")
            @test contains(result, "\\texttt{code}")

            # Bold and italic
            result = TeXDown.md_to_tex("**bold** and *italic*")
            @test contains(result, "\\textbf{bold}")
            @test contains(result, "\\textit{italic}")
        end
    end
end
