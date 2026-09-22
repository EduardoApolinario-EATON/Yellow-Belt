<#
=====================================================================
 setup_sharepoint.ps1
 Cria toda a estrutura SharePoint do projeto Expedicao:
   1. Pastas em  Documentos/EXPEDICAO/...
   2. Lista EXP_CICLOS_LOG
   3. Lista EXP_FALHAS_LOG
 Especificacao: 04_Improve/03_Integracao/02_Armazenamento_PDFs.md
                05_Control/04_Auditoria_Lite.md

 PRE-REQUISITOS
 --------------
   - PowerShell 7+ (recomendado)
   - Modulo PnP.PowerShell:
        Install-Module PnP.PowerShell -Scope CurrentUser
   - Permissao para criar listas/pastas no site SharePoint alvo.

 COMO USAR
 ---------
   pwsh ./setup_sharepoint.ps1 -SiteUrl "https://SEUTENANT.sharepoint.com/sites/SEUSITE"

   (opcional) -LibraryName "Documents"   # nome interno da biblioteca; em PT pode ser "Documentos"
              -RootFolder  "EXPEDICAO"
              -WhatIf                      # simula sem criar

 O script e idempotente: se algo ja existir, ele pula sem erro.
=====================================================================
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory = $true)]
    [string]$SiteUrl,

    # Nome interno da biblioteca de documentos. Em tenants PT-BR costuma ser "Documents"
    # mesmo que a UI mostre "Documentos". Ajuste se necessario.
    [string]$LibraryName = "Documents",

    [string]$RootFolder = "EXPEDICAO"
)

$ErrorActionPreference = "Stop"

# ---------------------------------------------------------------------
# 0. Conexao
# ---------------------------------------------------------------------
Write-Host "==> Conectando em $SiteUrl ..." -ForegroundColor Cyan
if (-not (Get-Module -ListAvailable -Name PnP.PowerShell)) {
    throw "Modulo PnP.PowerShell nao encontrado. Rode: Install-Module PnP.PowerShell -Scope CurrentUser"
}
Import-Module PnP.PowerShell -ErrorAction Stop
Connect-PnPOnline -Url $SiteUrl -Interactive

# ---------------------------------------------------------------------
# 1. Pastas
# ---------------------------------------------------------------------
$folders = @(
    "$RootFolder",
    "$RootFolder/INPUT",
    "$RootFolder/PROCESSADO",
    "$RootFolder/FAILED",
    "$RootFolder/FAILED/ocr",
    "$RootFolder/FAILED/chave_nao_encontrada",
    "$RootFolder/FAILED/chave_nao_existe_dataset",
    "$RootFolder/LOGS"
)

Write-Host "==> Criando estrutura de pastas em '$LibraryName/$RootFolder' ..." -ForegroundColor Cyan
foreach ($rel in $folders) {
    $sitePath = "$LibraryName/$rel"
    if ($PSCmdlet.ShouldProcess($sitePath, "Criar pasta")) {
        try {
            Resolve-PnPFolder -SiteRelativePath $sitePath | Out-Null
            Write-Host "   [ok] $sitePath"
        } catch {
            Write-Warning "   [falha] $sitePath -> $($_.Exception.Message)"
        }
    }
}

# ---------------------------------------------------------------------
# 2. Helpers de campo
# ---------------------------------------------------------------------
function Ensure-List {
    param([string]$Title)
    $list = Get-PnPList -Identity $Title -ErrorAction SilentlyContinue
    if ($null -eq $list) {
        if ($PSCmdlet.ShouldProcess($Title, "Criar lista")) {
            New-PnPList -Title $Title -Template GenericList -OnQuickLaunch | Out-Null
            Write-Host "   [ok] lista criada: $Title" -ForegroundColor Green
        }
    } else {
        Write-Host "   [skip] lista ja existe: $Title"
    }
}

function Ensure-Field {
    param(
        [string]$List,
        [string]$InternalName,
        [string]$DisplayName,
        [ValidateSet("Text","Number","DateTime","Choice","URL","Note")]
        [string]$Type,
        [string[]]$Choices
    )
    $existing = Get-PnPField -List $List -Identity $InternalName -ErrorAction SilentlyContinue
    if ($existing) { Write-Host "      [skip] campo ja existe: $List.$InternalName"; return }

    if (-not $PSCmdlet.ShouldProcess("$List.$InternalName", "Criar campo ($Type)")) { return }

    if ($Type -eq "Choice") {
        Add-PnPField -List $List -DisplayName $DisplayName -InternalName $InternalName `
            -Type Choice -Choices $Choices -AddToDefaultView | Out-Null
    } else {
        Add-PnPField -List $List -DisplayName $DisplayName -InternalName $InternalName `
            -Type $Type -AddToDefaultView | Out-Null
    }
    Write-Host "      [ok] campo: $List.$InternalName ($Type)" -ForegroundColor Green
}

# ---------------------------------------------------------------------
# 3. Lista EXP_CICLOS_LOG  (1 linha por ciclo)
#    spec: 05_Control/04_Auditoria_Lite.md secao 2
# ---------------------------------------------------------------------
Write-Host "==> Lista EXP_CICLOS_LOG ..." -ForegroundColor Cyan
Ensure-List -Title "EXP_CICLOS_LOG"
# 'Ciclo_ID' usa a coluna Title nativa renomeada
$titleField = Get-PnPField -List "EXP_CICLOS_LOG" -Identity "Title" -ErrorAction SilentlyContinue
if ($titleField -and $titleField.Title -ne "Ciclo_ID") {
    if ($PSCmdlet.ShouldProcess("EXP_CICLOS_LOG.Title", "Renomear para Ciclo_ID")) {
        Set-PnPField -List "EXP_CICLOS_LOG" -Identity "Title" -Values @{ Title = "Ciclo_ID" } | Out-Null
        Write-Host "      [ok] Title renomeado para Ciclo_ID"
    }
}
Ensure-Field -List "EXP_CICLOS_LOG" -InternalName "Inicio"             -DisplayName "Inicio"             -Type DateTime
Ensure-Field -List "EXP_CICLOS_LOG" -InternalName "Fim"                -DisplayName "Fim"                -Type DateTime
Ensure-Field -List "EXP_CICLOS_LOG" -InternalName "Total_NFs"          -DisplayName "Total_NFs"          -Type Number
Ensure-Field -List "EXP_CICLOS_LOG" -InternalName "Total_Classificadas" -DisplayName "Total_Classificadas" -Type Number
Ensure-Field -List "EXP_CICLOS_LOG" -InternalName "Total_Falhas"       -DisplayName "Total_Falhas"       -Type Number
Ensure-Field -List "EXP_CICLOS_LOG" -InternalName "Status"             -DisplayName "Status"             -Type Choice -Choices @("OK","OK_COM_FALHAS","ERRO")
Ensure-Field -List "EXP_CICLOS_LOG" -InternalName "Link_Pasta"         -DisplayName "Link_Pasta"         -Type URL
Ensure-Field -List "EXP_CICLOS_LOG" -InternalName "Operador"           -DisplayName "Operador"           -Type Text
Ensure-Field -List "EXP_CICLOS_LOG" -InternalName "Origem_PDFs"        -DisplayName "Origem_PDFs"        -Type Choice -Choices @("Caminho_A","Caminho_B")

# ---------------------------------------------------------------------
# 4. Lista EXP_FALHAS_LOG  (1 linha por PDF que falhou)
#    spec: 05_Control/04_Auditoria_Lite.md secao 3
# ---------------------------------------------------------------------
Write-Host "==> Lista EXP_FALHAS_LOG ..." -ForegroundColor Cyan
Ensure-List -Title "EXP_FALHAS_LOG"
$titleField2 = Get-PnPField -List "EXP_FALHAS_LOG" -Identity "Title" -ErrorAction SilentlyContinue
if ($titleField2 -and $titleField2.Title -ne "Ciclo_ID") {
    if ($PSCmdlet.ShouldProcess("EXP_FALHAS_LOG.Title", "Renomear para Ciclo_ID")) {
        Set-PnPField -List "EXP_FALHAS_LOG" -Identity "Title" -Values @{ Title = "Ciclo_ID" } | Out-Null
        Write-Host "      [ok] Title renomeado para Ciclo_ID"
    }
}
Ensure-Field -List "EXP_FALHAS_LOG" -InternalName "Arquivo_PDF" -DisplayName "Arquivo_PDF" -Type Text
Ensure-Field -List "EXP_FALHAS_LOG" -InternalName "Motivo"      -DisplayName "Motivo"      -Type Choice -Choices @("NF_NAO_ENCONTRADA","ERRO_MOVER","SUB_LOC_NULO","OUTRO")
Ensure-Field -List "EXP_FALHAS_LOG" -InternalName "Data"        -DisplayName "Data"        -Type DateTime
Ensure-Field -List "EXP_FALHAS_LOG" -InternalName "Detalhe"     -DisplayName "Detalhe"     -Type Note

# ---------------------------------------------------------------------
Write-Host ""
Write-Host "==> Concluido." -ForegroundColor Green
Write-Host "    Biblioteca: $LibraryName/$RootFolder (INPUT, PROCESSADO, FAILED/*, LOGS)"
Write-Host "    Listas:     EXP_CICLOS_LOG, EXP_FALHAS_LOG"
Write-Host ""
Write-Host "    Proximo passo: configurar permissoes" -ForegroundColor Yellow
Write-Host "      - Operador: contribuir em INPUT/, ler PROCESSADO/"
Write-Host "      - Conta de servico do Power Automate: editar EXPEDICAO/* e as 2 listas"
Disconnect-PnPOnline
