using Test
using TeXDown

# Include shared helpers once
include("test_helpers.jl")

@testset "TeXDown.jl" begin
    # Unit tests for each module
    include("test_md_to_latex.jl")
    include("test_fix_commonmark.jl")
    include("test_extensions.jl")
    include("test_clean_latex.jl")
    include("test_templates.jl")
    include("test_main.jl")

    # Integration tests
    include("integration/test_golden_files.jl")
end
