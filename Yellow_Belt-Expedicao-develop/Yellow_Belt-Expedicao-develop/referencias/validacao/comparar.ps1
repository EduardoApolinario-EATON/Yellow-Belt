# Compara Excel_PowerBI (report) x Excel_Producao (gabarito da macro)
# Junta pela CHAVE (44 digitos). Mede presenca, classificacao e ordem no conjunto comum.
param(
    [string]$Dir = "c:\repo\Yellow_Belt-Expedicao-develop\Yellow_Belt-Expedicao-develop\referencias\validacao"
)
$ErrorActionPreference = 'Stop'
$pbiPath  = Join-Path $Dir 'Excel_PowerBI.csv'
$prodPath = Join-Path $Dir 'Excel_Producao.csv'

function Get-Chave([string]$line) {
    $m = [regex]::Match($line, '\d{44}')
    if ($m.Success) { return $m.Value } else { return $null }
}

# ---------------- PRODUCAO (gabarito) ----------------
# indices por ';': 0 GUIA, 1 PAG, 2 NF, 3 DELIVERY, 4 NOTA_MAE, 5 SUB_LOCATOR, 6 VOL, 10 CHAVE
$prodLines = Get-Content -LiteralPath $prodPath
$prod = @{}
$prodOrder = New-Object System.Collections.Generic.List[string]
for ($i = 1; $i -lt $prodLines.Count; $i++) {
    $line = $prodLines[$i]
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    $chave = Get-Chave $line
    if (-not $chave) { continue }
    $c = $line -split ';'
    $nf  = if ($c.Count -gt 2) { $c[2].Trim() } else { '' }
    $sub = if ($c.Count -gt 5) { $c[5].Trim() } else { '' }
    $pag = if ($c.Count -gt 1) { $c[1].Trim() } else { '' }
    if (-not $prod.ContainsKey($chave)) {
        $prod[$chave] = [ordered]@{
            NF = $nf; DELIVERY = ($(if($c.Count -gt 3){$c[3].Trim()}else{''}))
            GUIA = ($(if($c.Count -gt 0){$c[0].Trim()}else{''}))
            NOTA_MAE = ($(if($c.Count -gt 4){$c[4].Trim()}else{''}))
            VOL = ($(if($c.Count -gt 6){$c[6].Trim()}else{''}))
            SUBS = (New-Object System.Collections.Generic.HashSet[string])
            FirstIdx = $i
        }
        [void]$prod[$chave].SUBS.Add($sub)
        $prodOrder.Add($chave)
    } else {
        [void]$prod[$chave].SUBS.Add($sub)
    }
}

# ---------------- POWERBI (report) ----------------
# indices: 0 ORDEM, 1 GUIA, 2 NF, 3 DELIVERY, 4 NOTA_MAE, 5 SUB_LOC, 6 VOL, 10 APTA, 11 CHAVE
$pbiLines = Get-Content -LiteralPath $pbiPath
$pbi = @{}
for ($i = 1; $i -lt $pbiLines.Count; $i++) {
    $line = $pbiLines[$i]
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    $chave = Get-Chave $line
    if (-not $chave) { continue }
    $c = $line -split ';'
    $ordem = 0; [void][int]::TryParse(($c[0].Trim()), [ref]$ordem)
    $pbi[$chave] = [ordered]@{
        ORDEM = $ordem; NF = $c[2].Trim(); DELIVERY = $c[3].Trim()
        GUIA = $c[1].Trim(); NOTA_MAE = $c[4].Trim(); SUB_LOC = $c[5].Trim()
        VOL = $c[6].Trim(); APTA = ($(if($c.Count -gt 10){$c[10].Trim()}else{''}))
    }
}

# ---------------- CONJUNTOS ----------------
$common = @($prod.Keys | Where-Object { $pbi.ContainsKey($_) })
$soProd = @($prod.Keys | Where-Object { -not $pbi.ContainsKey($_) })
$soPbi  = @($pbi.Keys  | Where-Object { -not $prod.ContainsKey($_) })

Write-Host "=================== RESUMO ==================="
Write-Host ("Producao (chaves unicas): {0}" -f $prod.Count)
Write-Host ("PowerBI  (chaves unicas): {0}" -f $pbi.Count)
Write-Host ("Em comum:        {0}" -f $common.Count)
Write-Host ("So na Producao:  {0}" -f $soProd.Count)
Write-Host ("So no PowerBI:   {0}" -f $soPbi.Count)

# ---------------- CLASSIFICACAO (comuns) ----------------
$divs = New-Object System.Collections.Generic.List[object]
foreach ($ch in $common) {
    $p = $prod[$ch]; $b = $pbi[$ch]
    $subOk  = $p.SUBS.Contains($b.SUB_LOC)
    $pagaP  = [bool]([regex]::IsMatch($p.GUIA, 'PAGA\s*GUIA'))
    $pagaB  = [bool]([regex]::IsMatch($b.GUIA, 'PAGA\s*GUIA'))
    $guiaOk = ($pagaP -eq $pagaB)
    $maeP   = if ($p.NOTA_MAE -ne '') { 'VIDE' } else { 'MAE' }
    $maeB   = if ($b.NOTA_MAE -ne '') { 'VIDE' } else { 'MAE' }
    $maeOk  = ($maeP -eq $maeB)
    if (-not ($subOk -and $guiaOk -and $maeOk)) {
        $divs.Add([pscustomobject]@{
            CHAVE = $ch; NF = $b.NF
            PBI_SUBLOC = $b.SUB_LOC; PROD_SUBLOCS = ($p.SUBS -join ' | '); SUB_OK = $subOk
            PBI_GUIA = $b.GUIA; PROD_GUIA = $p.GUIA; GUIA_OK = $guiaOk
            PBI_MAE = $maeB; PROD_MAE = $maeP; MAE_OK = $maeOk
        })
    }
}
$subDiv  = @($divs | Where-Object { -not $_.SUB_OK }).Count
$guiaDiv = @($divs | Where-Object { -not $_.GUIA_OK }).Count
$maeDiv  = @($divs | Where-Object { -not $_.MAE_OK }).Count
Write-Host "`n=============== CLASSIFICACAO (comuns) ==============="
Write-Host ("Divergencias totais: {0} de {1}" -f $divs.Count, $common.Count)
Write-Host ("  - SUB_LOC diferente:  {0}" -f $subDiv)
Write-Host ("  - GUIA diferente:     {0}" -f $guiaDiv)
Write-Host ("  - MAE/VIDE diferente: {0}" -f $maeDiv)

# ---------------- ORDEM (comuns) ----------------
$commonSortedProd = $common | Sort-Object { $prod[$_].FirstIdx }
$seq = @($commonSortedProd | ForEach-Object { $pbi[$_].ORDEM })
$inv = 0
$breaks = New-Object System.Collections.Generic.List[object]
for ($i = 0; $i -lt $seq.Count - 1; $i++) {
    if ($seq[$i] -gt $seq[$i + 1]) {
        $inv++
        if ($breaks.Count -lt 20) {
            $chA = $commonSortedProd[$i]; $chB = $commonSortedProd[$i + 1]
            $breaks.Add([pscustomobject]@{
                POS = $i
                NF_ANTERIOR = $pbi[$chA].NF; ORDEM_ANTERIOR = $pbi[$chA].ORDEM
                NF_SEGUINTE = $pbi[$chB].NF; ORDEM_SEGUINTE = $pbi[$chB].ORDEM
            })
        }
    }
}
Write-Host "`n=================== ORDEM (comuns) ==================="
Write-Host ("Quebras de sequencia (ORDEM do PBI nao cresce na ordem da producao): {0} de {1}" -f $inv, [Math]::Max(0, $seq.Count - 1))
if ($seq.Count -gt 1) {
    $pct = [Math]::Round(100.0 * ($seq.Count - 1 - $inv) / ($seq.Count - 1), 1)
    Write-Host ("Concordancia de ordem: {0}%" -f $pct)
}

# ---------------- EXPORTA ----------------
$divs   | Export-Csv (Join-Path $Dir 'divergencias_classificacao.csv') -NoTypeInformation -Encoding UTF8 -Delimiter ';'
$breaks | Export-Csv (Join-Path $Dir 'quebras_ordem.csv') -NoTypeInformation -Encoding UTF8 -Delimiter ';'
$soProd | ForEach-Object { [pscustomobject]@{ CHAVE = $_; NF = $prod[$_].NF; SUBS = ($prod[$_].SUBS -join ' | ') } } | Export-Csv (Join-Path $Dir 'so_producao.csv') -NoTypeInformation -Encoding UTF8 -Delimiter ';'
$soPbi  | ForEach-Object { [pscustomobject]@{ CHAVE = $_; NF = $pbi[$_].NF; SUB_LOC = $pbi[$_].SUB_LOC; ORDEM = $pbi[$_].ORDEM } } | Export-Csv (Join-Path $Dir 'so_powerbi.csv') -NoTypeInformation -Encoding UTF8 -Delimiter ';'
Write-Host "`nGerados: divergencias_classificacao.csv, quebras_ordem.csv, so_producao.csv, so_powerbi.csv"
