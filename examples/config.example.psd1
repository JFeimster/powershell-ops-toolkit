@{
    ProjectRoots = @(
        'C:\Users\you\Documents\GitHub'
        'C:\Users\you\Projects'
    )

    ExcludedDirectories = @(
        '.git'
        'node_modules'
        '.next'
        'dist'
        'build'
        'coverage'
        'vendor'
    )

    DefaultEditor = 'code'
    StructuredOutput = $true
}
