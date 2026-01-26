using Test
using TeXDown

# Get the project root directory
const PROJECT_ROOT = dirname(dirname(@__DIR__))
const EXAMPLES_DIR = joinpath(PROJECT_ROOT, "examples")

"""
    normalize_for_comparison(str)

Normalize a string for comparison by:
- Trimming trailing whitespace from each line
- Removing trailing whitespace at end of file
- Normalizing line endings
"""
function normalize_for_comparison(str::String)
    lines = split(str, "\n")
    lines = [rstrip(line) for line in lines]
    # Remove trailing empty lines
    while !isempty(lines) && isempty(lines[end])
        pop!(lines)
    end
    return join(lines, "\n")
end

@testset "Golden File Tests" begin

    @testset "todo_list.md -> todo_list.tex" begin
        md_file = joinpath(EXAMPLES_DIR, "todo_list.md")
        expected_tex_file = joinpath(EXAMPLES_DIR, "todo_list.tex")

        @test isfile(md_file)
        @test isfile(expected_tex_file)

        # Generate TeX from markdown
        result = make_tex(md_file, todo_list; save=false)
        expected = read(expected_tex_file, String)

        # Compare normalized versions
        result_normalized = normalize_for_comparison(result)
        expected_normalized = normalize_for_comparison(expected)

        @test result_normalized == expected_normalized
    end

    @testset "research_note.md -> research_note.tex" begin
        md_file = joinpath(EXAMPLES_DIR, "research_note.md")
        expected_tex_file = joinpath(EXAMPLES_DIR, "research_note.tex")

        @test isfile(md_file)
        @test isfile(expected_tex_file)

        # Generate TeX from markdown
        result = make_tex(md_file, research_note; save=false)
        expected = read(expected_tex_file, String)

        # Compare normalized versions
        result_normalized = normalize_for_comparison(result)
        expected_normalized = normalize_for_comparison(expected)

        @test result_normalized == expected_normalized
    end

    @testset "recipe.md -> recipe.tex" begin
        md_file = joinpath(EXAMPLES_DIR, "recipe.md")
        expected_tex_file = joinpath(EXAMPLES_DIR, "recipe.tex")

        @test isfile(md_file)
        @test isfile(expected_tex_file)

        # Generate TeX from markdown
        result = make_tex(md_file, recipe; save=false)
        expected = read(expected_tex_file, String)

        # Compare normalized versions
        result_normalized = normalize_for_comparison(result)
        expected_normalized = normalize_for_comparison(expected)

        @test result_normalized == expected_normalized
    end
end
