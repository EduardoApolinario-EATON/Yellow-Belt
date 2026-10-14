# 📚 Integração — Overview

> **Índice revisado: 2026-10-14.** Integração funcional confirmada com SharePoint; caminhos, retenção e estrutura física a confirmar. Os roteiros de criação abaixo não comprovam a estrutura existente.

Rotina vigente: [Manual do Operador](../../05_Control/05_Manual_Operador.md). Configuração e transferência: [Manual Técnico](../../docs_ferramenta/01_Documentacao_Tecnica.md) e [P02/P16](../../03_Analyze/07_Open_Questions.md). Não executar setup_sharepoint.ps1 para “alinhar” documentação; revisar previamente com TI em ambiente autorizado.

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
