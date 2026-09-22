# 📚 Integração — Overview

> Como tudo se conecta: PDFs, Power BI, Power Automate, SharePoint.  
> **Último update:** 2026-06-22

---

## 🎯 Objetivo

Documentar como os componentes se integram:
1. Onde PDFs começam (Synchro)
2. Como chegam ao Power Automate (OneDrive/SharePoint)
3. Como Power BI dataset alimenta a classificação
4. Onde PDFs acabam (organizados por prisma)

---

## 📚 Documentos

| Doc | Função |
|---|---|
| [01_Fluxo_Operador.md](01_Fluxo_Operador.md) | O que o operador faz no TO-BE |
| [02_Armazenamento_PDFs.md](02_Armazenamento_PDFs.md) | CRÍTICO — Opção A vs investigação paralela |
| [03_Setup_SharePoint_Manual.md](03_Setup_SharePoint_Manual.md) | Passo-a-passo manual: pastas + Lists `EXP_CICLOS_LOG` / `EXP_FALHAS_LOG` |
| [setup_sharepoint.ps1](setup_sharepoint.ps1) | Script PnP PowerShell (alternativa automatizada; requer PS7 + app Entra ID) |

---

## 🔗 Referência

- [`../../01_Define/04_Regras_Negocio.md`](../../01_Define/04_Regras_Negocio.md)
- [`../01_PowerBI/01_Dataset_Schema.md`](../01_PowerBI/01_Dataset_Schema.md)
- [`../02_PowerAutomate/01_Fluxo_Classificador.md`](../02_PowerAutomate/01_Fluxo_Classificador.md)
