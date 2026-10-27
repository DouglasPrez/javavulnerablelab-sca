param(
    [string]$MavenCommand = 'mvn',
    [string]$LocalRepository,
    [string]$WorkingDirectory = (Join-Path ([IO.Path]::GetTempPath()) ('jvl-log4j-test-' + [guid]::NewGuid()))
)
$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path $PSScriptRoot -Parent
New-Item -ItemType Directory -Path $WorkingDirectory -Force | Out-Null
$libs = Join-Path $WorkingDirectory 'lib'
$mavenArgs = @('-B', '-ntp')
if ($LocalRepository) { $mavenArgs += "-Dmaven.repo.local=$LocalRepository" }
$mavenArgs += @('org.apache.maven.plugins:maven-dependency-plugin:3.8.1:copy-dependencies', '-DincludeGroupIds=org.apache.logging.log4j', "-DoutputDirectory=$libs")
Push-Location $repoRoot
try {
    & $MavenCommand @mavenArgs
    if ($LASTEXITCODE -ne 0) { throw 'Maven dependency resolution failed.' }
    $jars = @(Get-ChildItem -LiteralPath $libs -Filter '*.jar')
    if ($jars.Count -ne 2) { throw 'Expected exactly the resolved Log4j API and Core JARs.' }
    $classpath = ($jars.FullName -join [IO.Path]::PathSeparator)
    $javaBin = if ($env:JAVA_HOME) { Join-Path $env:JAVA_HOME 'bin' } else { Split-Path (Get-Command java).Source }
    & (Join-Path $javaBin 'javac.exe') -cp $classpath -d $WorkingDirectory (Join-Path $PSScriptRoot 'LogLookupSmoke.java')
    if ($LASTEXITCODE -ne 0) { throw 'Smoke test compilation failed.' }
    $config = Join-Path $repoRoot 'src\main\resources\log4j2.xml'
    $output = & (Join-Path $javaBin 'java.exe') "-Dlog4j.configurationFile=$config" -cp ($WorkingDirectory + [IO.Path]::PathSeparator + $classpath) LogLookupSmoke 2>&1 | Out-String
    $javaExitCode = $LASTEXITCODE
    Write-Output $output
    if ($javaExitCode -ne 0) { throw 'Smoke test execution failed.' }
    foreach ($expected in @('Search query: consulta-normal', 'Search query: ${java:version}', 'Search query: ${lower:ABC}')) {
        if (-not $output.Contains($expected)) { throw "Message interpolation regression: missing literal '$expected'." }
    }
    Write-Output 'PASS: ordinary logging works and user-controlled lookup syntax remains literal.'
} finally {
    Pop-Location
}
