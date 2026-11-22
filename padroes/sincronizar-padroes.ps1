<#
  Copia o padrão AUTVS para um repositório (a cópia é gerada: não editar nos repos).
  Uso:  .\sincronizar-padroes.ps1 -Repo D:\Dev\Projetos\autvs\autvs_app -Tipo ts
        .\sincronizar-padroes.ps1 -Repo D:\Dev\Projetos\autvs\autvs_api -Tipo dotnet
  Não faz git add/commit/push: quem roda revisa o diff e abre o PR.
#>
param(
  [Parameter(Mandatory = $true)][string]$Repo,
  [Parameter(Mandatory = $true)][ValidateSet("ts", "dotnet")][string]$Tipo
)
$ErrorActionPreference = "Stop"
$utf8 = New-Object System.Text.UTF8Encoding($false)   # UTF-8 sem BOM; o PS 5.1 lê sem BOM como ANSI, então sempre via .NET
$raiz = $PSScriptRoot
if (-not (Test-Path (Join-Path $Repo ".git"))) { throw "Não é um repositório git: $Repo" }

New-Item -ItemType Directory -Force (Join-Path $Repo "docs") | Out-Null
New-Item -ItemType Directory -Force (Join-Path $Repo ".github\workflows") | Out-Null

Copy-Item (Join-Path $raiz "padrao-codigo.md") (Join-Path $Repo "docs\padrao-codigo.md") -Force
Copy-Item (Join-Path $raiz "PULL_REQUEST_TEMPLATE.md") (Join-Path $Repo ".github\PULL_REQUEST_TEMPLATE.md") -Force
Copy-Item (Join-Path $raiz "github\dependabot.yml") (Join-Path $Repo ".github\dependabot.yml") -Force
Copy-Item (Join-Path $raiz "github\workflows\seguranca.yml") (Join-Path $Repo ".github\workflows\seguranca.yml") -Force

if ($Tipo -eq "ts") {
  # Só cria se não existir: não sobrescreve configuração própria do repo.
  $p = Join-Path $Repo ".prettierrc.json"
  if (-not (Test-Path $p)) { Copy-Item (Join-Path $raiz "ts\.prettierrc.json") $p }
} else {
  foreach ($f in ".editorconfig", "Directory.Build.props") {
    $d = Join-Path $Repo $f
    if (-not (Test-Path $d)) { Copy-Item (Join-Path $raiz "dotnet\$f") $d }
  }
  $w = Join-Path $Repo ".github\workflows\seguranca.yml"
  [IO.File]::WriteAllText($w, ([IO.File]::ReadAllText($w, $utf8) -replace 'javascript-typescript', 'csharp'), $utf8)
}

# Garante o bloco no CLAUDE.md (cria ou acrescenta uma única vez).
$claude = Join-Path $Repo "CLAUDE.md"
$bloco = [IO.File]::ReadAllText((Join-Path $raiz "CLAUDE-bloco-padrao.md"), $utf8)
if (-not (Test-Path $claude)) { [IO.File]::WriteAllText($claude, $bloco, $utf8) }
elseif (([IO.File]::ReadAllText($claude, $utf8)) -notmatch [regex]::Escape("@docs/padrao-codigo.md")) {
  [IO.File]::AppendAllText($claude, ("`n" + $bloco), $utf8)
}
Write-Host "Padrão sincronizado em $Repo. Revise 'git diff' e abra o PR."
Write-Host "Lembrete: CODEOWNERS (ver padroes\github\CODEOWNERS.exemplo) e branch protection são configurados à parte no GitHub."
