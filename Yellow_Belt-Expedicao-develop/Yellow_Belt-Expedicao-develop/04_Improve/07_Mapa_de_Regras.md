# Mapa de Regras - Implementação Atual e Legado

> **Revisão vigente: 2026-10-14.** Este mapa separa implementação observada de regra histórica e aceite de negócio. Base: [TMDL atual](../../../Dataset/Modelo_Expedicao_ATUAL.SemanticModel/definition/tables/NotasFiscais.tmdl). O catálogo antigo abaixo é referência do legado, não evidência de migração integral.

## Regras observadas no Power BI

| Bloco | Implementação atual | Diferença / validação necessária |
|---|---|---|
| Entrada | ORG 1344, COMPLETE_FLAG Y, duas batch sources AFT | Sem filtro local de hoje nem exclusão geral local de canceladas |
| Exclusões | Tipo SI COMPL PRECO C/AR e UF EX | Nulos são mantidos; origem Bronze define parte do universo |
| Status | CLL 2 FINALIZADO; 4/6 CANCELADO; nulo SEM_STATUS; demais ERRO | Cancelada pode existir no modelo como não apta |
| Aptidão | FINALIZADO + CASE_RILA OK + CHAVE_LEN 44 | Não valida dígitos/DV, guia paga, existência de PDF ou prisma |
| RILA | Soma QUANTITY_ORDERED AR = soma SHIPPED_QUANTITY OE, ambas não nulas | Não presumir equivalência integral ao agrupamento SQL por delivery; testar paridade |
| Guia | AC/AM/AP/RO/RR sempre; AL/DF/GO/MS/TO se ICMS_ST não zero | Usa imposto, não EXTENDED_AMOUNT de produtos; regra fiscal deve ser homologada |
| ICMS-ST | Lookup ativo -> TAX_CODE -> VAT_TAX_ID -> TAX EXTENDED_AMOUNT | Lookup/configuração pertencem às origens |
| FCP-ST | Dez VAT_TAX_ID fixos | Validar vigência com Fiscal |
| Prisma | Óleo/item; senão GA19; senão locator; concatena prioridade reconhecida | Categoria EMBREAGEM_DSH não implementada; prisma ausente não impede APTA |
| Locator | Prefere WSH Y/C não nulo; mínimo textual; fallback mínimo disponível | Não exige STG; conferir LOC_ALL/SUBINV_ALL/REL_ALL |
| WSH | WSH_DOC, recorte local 45 dias e deduplicação | Não usar orientação histórica WSH_DOC_CUR como descrição atual |
| Mãe/filha | Menor NF numérica por delivery; filhas referenciam mãe e recebem volume 0 | Não é repetição do par NF+delivery nem substring da chave |
| Ordenação | Guia desc, SORT_SUBLOC da mãe asc, delivery asc, NF asc; índice 1..n | Não é ID persistente; filtro visual não renumera |
| Destino | Guia antes de aptidão; depois óleo/apta, pronto/apta e exceções | AGUARDANDO GUIA pode conter não apta; pasta não libera embarque |
| Arquivo | PAGA GUIA ou EXPEDICAO + letra/posição + NF; demais DFE/chave | Sem data no nome atual; sequência do spooler requer teste |
| CNPJ | Dígitos de HZ_PARTIES.JGZZ_FISCAL_CODE | Não replica necessariamente CNPJ BILL_TO/filial de 14 dígitos |
| Cliente | PARTY_NAME completo | Não aplica SUBSTR de 20 caracteres |
| Histórico | STATUS_CICLO em DAX por chave em lista importada | Não prova bloqueio do fluxo ou impressão física |
| Multi-locator | Flag de mais de um locator distinto em LOC_ALL | Visual usa NotasFiscais; auxiliar MesmaNF_OutroLocator está vazia |

## Matriz de destino: ordem importa

1. PAGA_GUIA SIM: AGUARDANDO GUIA, independentemente de APTA.
2. Sem guia, APTA Sim e CFOP 6.655/5.655: OLEO.
3. Sem guia, demais APTA Sim: PRONTO.
4. Demais: EXCECAO/* pelo MOTIVO, que prioriza comprimento inválido da chave antes dos erros fiscal/delivery.

Nenhuma dessas regras comprova liberação da guia ou impressão. O cálculo de guia e a atividade do botão Paga Guia são contratos distintos.

## Fora da comprovação desta revisão

Inscrições estaduais, categoria de embreagem, e-mails, PIN, ZIP, timer 06:30, retorno de guia, limpeza por idade e limites do banco legado não são funcionalidades comprovadas pelo PBIP. Download manual/API/RPA SYNCHRO depende do procedimento confirmado. Power Automate é funcional conforme relato, mas seu algoritmo precisa de export para auditoria.

## Fontes e precedência documental

Para explicar comportamento da cópia: TMDL/JSON atual. Para autorizar regra: homologação de negócio, ainda pendente. Para paridade: queries e macro como referências históricas, comparadas com amostra autorizada. O código descreve o que ocorre; não define sozinho o que deve ser fiscalmente autorizado.

Referências: [Manual Técnico](../docs_ferramenta/01_Documentacao_Tecnica.md), [Dicionário](01_PowerBI/01_Dataset_Schema.md), [Pendências](../03_Analyze/07_Open_Questions.md).

<details>
<summary>Catálogo do legado de junho/2026: histórico e hipóteses de migração</summary>

> Catálogo **exaustivo** de todas as regras de negócio existentes (queries Oracle + macro VBA + `IMPRESSAO.xlsb`), com a **fonte** de cada uma e o **status de implementação** na solução Power BI + Power Automate.
> **Última atualização:** 2026-06-23
> **Objetivo:** Saber, regra a regra, **o que dá para implementar** e **entender o fluxo completo**.

---

## 📚 Fontes mapeadas

| Fonte | Arquivo | O que contém |
|---|---|---|
| **Query Oracle (revisada)** | [QUERY_EXPEDICAO_REVISADA.sql](../queries/QUERY_EXPEDICAO_REVISADA.sql) | Filtros de entrada + colunas derivadas (SUB_LOC, CFOP, CASE_RILA, STATUS, impostos) |
| **Query óleo (Part 2)** | [IMPRESSAO_PART_2_OLEO.sql](../queries/IMPRESSAO_PART_2_OLEO.sql) | Mesma estrutura, filtrada **para** CFOP 6.655/5.655 (óleo) |
| **Macro VBA** | [referencias/macro_antiga/Modulos_Macro.txt](../referencias/macro_antiga/Modulos_Macro.txt) | Limpeza, PAGA_GUIA, roteamento, renomeação, pastas, e-mails |
| **IMPRESSAO.xlsb** | local (não versionado) | Abas `EXECUTAR`, `NOTAS FINALIZADAS`, `Select ra_site_uses_all` |

> **Legenda de status:** ✅ implementável agora · 🟡 implementável com nuance/decisão · ⬜ depende de confirmação do time · 🚫 não migra (vira ação humana/externa)

---

## 🔄 Fluxo completo (AS-IS)

```mermaid
flowchart TD
    Q[Query Oracle R12<br/>3 partes: normal + óleo] --> F[Filtros de entrada<br/>exclui cancelado/export/não-AFT]
    F --> D[Colunas derivadas<br/>SUB_LOC, CFOP, CASE_RILA, STATUS]
    D --> L[Limpeza macro<br/>chave vazia, duplicados, já finalizadas]
    L --> PG{PAGA_GUIA?}
    PG -->|Sim| AG[/AGUARDANDO GUIA/<br/>+ BANCO DE DADOS PAGA GUIA]
    PG -->|Não| RT{CASE_RILA x STATUS}
    RT -->|OK + FINALIZADO| PR[PRONTO → imprime]
    RT -->|demais| EX[Exceção → e-mail fiscal]
    PR --> RN[Renomeia A/B/C/D + agrupa por SUB_LOC]
    RN --> NF[Registra chave em NOTAS FINALIZADAS<br/>anti-reimpressão]
    AG -.->|Faturamento libera guia<br/>manual| RET[Cola chave liberada<br/>reentra no fluxo]
    RET --> PR
```

---

## 1️⃣ Filtros de entrada (Query Oracle)

> Definem **o que entra** no dataset. Fonte: `QUERY_EXPEDICAO_REVISADA`, cláusula `WHERE` (linhas ~328-345).

| # | Regra | Código | Status |
|---|---|---|---|
| F.1 | Apenas organização **1344** (Valinhos AFT) | `A.ORG_ID = '1344'` | ✅ |
| F.2 | Apenas batch sources AFT automáticas | `D.NAME IN ('VALI AFT VENDA AUTOMATICA', '... OLD')` | ✅ |
| F.3 | Exclui **canceladas/inutilizadas** | `B.STATUS NOT IN ('4','6')` | ✅ |
| F.4 | Exclui **exportação** (UF = EX) | `STATE not in ('EX')` | ✅ |
| F.5 | Exclui complemento de preço | `C.NAME NOT IN ('SI COMPL PRECO C/AR')` | ✅ |
| F.6 | Query **normal** exclui óleo; query **óleo** inclui só ele | `C.GLOBAL_ATTRIBUTE3 NOT IN ('6.655','5.655')` | ✅ |
| F.7 | Janela de datas (parametrizada) | `B.LAST_UPDATE_DATE BETWEEN &DATA_INICIO AND &DATA_FIM` | ✅ |
| F.8 | Linha de produto (não imposto) | `CTLA.LINE_TYPE = 'LINE'` · `WDD.SOURCE_CODE = 'OE'` | ✅ |

---

## 2️⃣ Colunas derivadas (Query Oracle)

> Calculadas no SQL. Estas são as colunas que **alimentam o roteamento** depois.

| # | Coluna | Regra | Status |
|---|---|---|---|
| D.1 | **SUB_LOC** | Se CFOP 6.655/5.655 → `OLEO_<item>`; senão se `GLOBAL_ATTRIBUTE19` nulo → `SEG1.SEG2.SEG3` (locator); senão `GLOBAL_ATTRIBUTE19`. Concatena `SHIPMENT_PRIORITY_CODE` (UNIDADE PARADA DSH / EMBREAGENS / DIRECT SHIPMENT) | 🟡 (replicar no Power Query (M)/DAX) |
| D.2 | **SUB_LOC especial EMBREAGEM_DSH** | Categoria `BRA MFG = 'A'` **E** prioridade `DIRECT SHIPMENT` → sufixo `EMBREAGEM_DSH` | 🟡 |
| D.3 | **CNPJ** | `SUBSTR(<BILL_TO global_attr3+4+5>, 2, 14)` | ✅ |
| D.4 | **CLIENTE** | `SUBSTR(CUSTOMER_NAME, 1, 20)` | ✅ |
| D.5 | **UF** | `STATE` do endereço SHIP_TO | ✅ |
| D.6 | **CHAVE_DE_ACESSO** | `'DFE' || B.ATTRIBUTE2` | ✅ |
| D.7 | **CFOP + ST** | `GLOBAL_ATTRIBUTE3 || (' S_ST' se soma de impostos ICMS-ST = 0, senão ' C_ST')` | ✅ |
| D.8 | **CASE_RILA** | `'OK'` se `SUM(QUANTITY_ORDERED) = SUM(SHIPPED_QUANTITY)`; senão `'VERF_RILA'` | ✅ |
| D.9 | **STATUS** | `DECODE`: 1/3/5/7/8→`ERRO`; 4/6→`CANCELADO`; 2→`FINALIZADO` | ✅ |
| D.10 | **ICMS_ST** | `SUM(EXTENDED_AMOUNT)` das linhas TAX em códigos ICMS-ST | ✅ |
| D.11 | **FCP_ST** | `SUM(EXTENDED_AMOUNT)` das linhas TAX em códigos FCP | ✅ |
| D.12 | **INSCRICAO_UF** | `DECODE(UF → inscrição estadual da Eaton)` (tabela por UF) | ✅ |
| D.13 | **INSCRICAO_CLIENTE** | Inscrição estadual do cliente (BILL_TO) | ✅ |

> **CASE_RILA decodificado:** compara **quantidade pedida vs. quantidade efetivamente embarcada**. Se baterem, a entrega está íntegra (`OK`); se não, há divergência a verificar (`VERF_RILA`).

> **Quem define `CASE_RILA` e `STATUS` (origem, não é calculado por nós):**
> - **`CASE_RILA = OK`** → definido pelo **armazém**: o operador bipa e confirma o embarque (*ship confirm*); se `SHIPPED_QUANTITY = QUANTITY_ORDERED`, a entrega é íntegra. É indicador de **integridade física**.
> - **`STATUS = FINALIZADO`** → definido pelo **fisco/SEFAZ**: a integração Synchro/Oracle grava `STATUS = 2` quando a **NF-e é autorizada**. É indicador de **validade fiscal**.
> - O dataset apenas **lê** `QUANTITY_ORDERED`, `SHIPPED_QUANTITY` e `STATUS` do Oracle e aplica as fórmulas — a decisão já aconteceu na origem. O portão de impressão (`OK + FINALIZADO`) = **embarque íntegro + NF-e autorizada**.

---

## 3️⃣ Limpeza / exclusões (Macro VBA)

> Fonte: `Modulos_Macro.txt`, Módulo 2.

| # | Regra | Linha | Status |
|---|---|---|---|
| C.1 | Exclui **exportação** (`EX*` no tipo de saída) — reforço do filtro F.4 | 360-377 | ✅ |
| C.2 | Exclui **STATUS = CANCELADO** (VLOOKUP na query) | 382-423 | ✅ |
| C.3 | Marca **chave vazia** como `DFE999999999` e depois deleta | 439-444 / 1108-1130 | ✅ |
| C.4 | Exclui linhas com **NF e DELIVERY vazios** | 412-423 | ✅ |
| C.5 | Exclui chave `VE_DE_ACESSO` (lixo de extração) | 1142-1143 | ✅ |
| C.6 | Remove **duplicados** por `NF + DELIVERY + LOCATOR` | 1137-1158 / 1784 | ✅ |
| C.7 | Remove notas **já finalizadas** (anti-reimpressão — ver §9) | 999-1041 | ✅ |
| C.8 | Valida estrutura do arquivo (`coluna D = "SUB_LOC"`) | 449 | ✅ |

---

## 4️⃣ PAGA_GUIA — estados incentivados (Macro VBA)

> Fonte: linhas 1240-1246. **Atenção: a condição varia por UF** (corrige documentação anterior que tratava todos com valor ≠ 0).

| UF | Condição | Status |
|---|---|---|
| **AC, AM, AP, RO, RR** | **Incondicional** (sempre paga guia) | ✅ |
| **AL, DF, GO, MS, TO** | Só se **`EXTENDED_AMOUNT <> 0`** (há imposto) | ✅ |
| **MA** | ❌ **Removida** (estava condicional, foi comentada na macro) | ℹ️ histórico |

```text
GUIA = "PAGA GUIA" se:
   UF ∈ {AC, AM, AP, RO, RR}
   OU (UF ∈ {AL, DF, GO, MS, TO} E EXTENDED_AMOUNT <> 0)
SENÃO "NÃO PAGA"
```

- Coluna final: `GUIA` = `"PAGA GUIA"` / `"NÃO PAGA"` (linhas 1213-1218).
- **Ação:** PAGA GUIA **não** imprime no fluxo normal → vai para `AGUARDANDO GUIA/` + `BANCO DE DADOS - PAGA GUIA.xlsb` (ver §10).

---

## 5️⃣ Roteamento — matriz CASE_RILA × STATUS (Macro VBA)

> Fonte: linhas 775-807. Decisão para notas que **não** são PAGA_GUIA.

| `CASE_RILA` | `STATUS` | Rótulo | Destino AS-IS | Destino TO-BE (proposto) | Status |
|---|---|---|---|---|---|
| OK | FINALIZADO | *(sem erro)* | ✅ **IMPRIME** | `/PRONTO/` | ✅ |
| OK | ≠ FINALIZADO | `ERRO NF` | E-mail fiscal | `/EXCECAO/ERRO_NF/` | 🟡 decisão |
| ≠ OK | FINALIZADO | `VERIFICAR DELIVERY` | E-mail fiscal | `/EXCECAO/VERIFICAR_DELIVERY/` | 🟡 decisão |
| ≠ OK | ≠ FINALIZADO | `ERRO DELIVERY + ERRO NF` | E-mail fiscal | `/EXCECAO/ERRO_DELIVERY_NF/` | 🟡 decisão |

> **Precedência:** `PAGA_GUIA` é avaliado **antes** da matriz. Decisão pendente: no TO-BE a exceção vira **pasta** ou mantém **e-mail**? (ver [07_Open_Questions.md](../03_Analyze/07_Open_Questions.md) §5b).

---

## 6️⃣ Nota mãe / nota filha / agrupamento (Macro VBA)

| # | Regra | Linha | Status |
|---|---|---|---|
| M.1 | **Nota mãe vs filha (VIDE):** se `NF + DELIVERY` = linha anterior → é VIDE (filha), célula vazia; senão é nota mãe | 745-752 / 951-970 | ✅ |
| M.2 | Mesma NF em **mais de um LOCATOR** → flag `VERDADEIRO` + aba "MESMA NF EM OUTRO LOCATOR" | 1270-1278 / 1896-1928 | 🟡 |
| M.3 | **Volume = 0** para VIDE nota (não recontar volume da mãe) | 1230-1233 | 🟡 |
| M.4 | Agrupa por DELIVERY/LOCATOR para impressão no mesmo prisma | 948-949 / 1219-1226 | ✅ |

---

## 7️⃣ SUB_LOC especiais (Query + dados reais)

> Padrões observados na aba `Select ra_site_uses_all` e no SQL.

| Padrão | Significado | Origem | Status |
|---|---|---|---|
| `STG.XXXX.NNN` | Locator físico normal (prisma) | `SEG1.SEG2.SEG3` | ✅ |
| `OLEO_<item>` | Item de óleo (CFOP 6.655/5.655) | CASE no SQL | 🟡 |
| `EMBREAGEM_DSH` | Embreagem em Direct Shipment | CASE no SQL (D.2) | 🟡 |
| `...UNIDADE PARADA DSH / EMBREAGENS / DIRECT SHIPMENT` | Prioridade de envio concatenada | `SHIPMENT_PRIORITY_CODE` | 🟡 |
| `STG.GUIA.NNN` / `STGD.CASE.GUIA` | Locators marcados para guia/case | dado real | ⬜ confirmar com time |

---

## 8️⃣ Renomeação / ordem de impressão (Macro VBA)

| # | Regra | Linha | Status |
|---|---|---|---|
| R.1 | **Prefixo A/B/C/D por nº de dígitos da linha:** 1 díg→`A`, 2→`B`, 3→`C`, 4→`D` (garante ordem alfabética na impressão do Windows) | 1278-1295 | ✅ |
| R.2 | Nome final: `EXPEDICAO <X><n> - NF <nf> - <data>.pdf` (normal) ou `DFE<chave>.pdf` (banco) | 1307-1308 | ✅ |
| R.3 | Prefixo equivalente para guias: `PAGA GUIA A/B/C/D` | 2688-2717 | ✅ |
| R.4 | **Nº de páginas por tamanho do arquivo** (faixas KB: 1pg 22-30KB … >5pg >110KB) | 1320-1325 | 🟡 (heurística frágil) |

---

## 9️⃣ Registro anti-reimpressão (Macro VBA + aba NOTAS FINALIZADAS)

| # | Regra | Linha | Status |
|---|---|---|---|
| A.1 | Aba `NOTAS FINALIZADAS`, **coluna E** = registro-mestre de chaves já impressas | — | ✅ |
| A.2 | `VLOOKUP` de cada chave nova contra coluna E → se existe, **não reimprime** | 999-1041 | ✅ |
| A.3 | Ao finalizar, **cola a chave** na coluna E + timestamp `NOW()` na coluna C | 1722-1751 | ✅ |
| A.4 | **Capacidade 20.000** linhas; ao atingir, deleta as 500 mais antigas | 116-135 | ✅ (no TO-BE: tabela de controle) |

> No TO-BE isto vira uma **tabela/coluna de controle** (NFs já expedidas) que o fluxo consulta para não reprocessar o mesmo PDF.

---

## 🔟 PAGA-GUIA — fluxo completo (ida + volta)

| # | Regra | Linha | Status |
|---|---|---|---|
| G.1 | Notas PAGA_GUIA → pasta `AGUARDANDO GUIA/` + acumuladas em `BANCO DE DADOS - PAGA GUIA.xlsb` | 1545-1559 / 1650-1700 | 🟡 |
| G.2 | Módulo `IMPRESSAO_PAGA_GUIA` (timer diário 06:30) renomeia, zipa e **envia e-mail ao Faturamento** (GFSS) pedindo gerar/pagar as guias | 2663-2845 | 🚫 (handoff externo) |
| G.3 | Após envio, **limpa** o banco de dados (linhas 2:400) | 2862-2869 | 🟡 |
| G.4 | **Gatilho manual:** operador clica botão "PAGA GUIA" **quando o Faturamento solicita** (aba EXECUTAR) | EXECUTAR L30-32 | 🚫 (ação humana) |
| G.5 | **Retorno:** guia liberada → chave liberada é **colada na coluna E** de NOTAS FINALIZADAS e a nota **reentra** no fluxo de saída | 2784 (instrução) | ⬜ depende de sinal no Oracle |

> **Conclusão:** a paga-guia tem **ida** (expedição empacota e notifica o Faturamento) e **volta** (Faturamento libera → nota reentra). A geração da guia é **externa** (time fiscal). Pergunta-chave ao time: *existe status no Oracle R12 que indique "guia paga/liberada"?* — define se a **volta** é automatizável.

---

## 1️⃣1️⃣ E-mails (Macro VBA)

| # | Gatilho | Destinatário (papel) | Assunto | Anexos | Status TO-BE |
|---|---|---|---|---|---|
| E.1 | Há erros NF/DELIVERY | Fiscal/Billing | `ERRO **** AFTERMARKETING` | — | 🟡 vira pasta/notificação |
| E.2 | Há novas notas impressas | Expedição/Billing | `AFTERMARKETING - NOTAS FINALIZADAS` | relatório + ZIP + manual | 🚫 substituído por pasta/PDF |
| E.3 | Sem novas notas | Expedição/Billing | `AFTERMARKETING` | — | 🚫 |
| E.4 | Há notas paradas | Fiscal/Billing | `NOTAS PARADAS - ULTIMO RELATORIO` | relatório | 🟡 |
| E.5 | Rotina paga-guia | **Faturamento (GFSS)** | `## GUIAS E PINS ##` | relatório + ZIP + manual | 🚫 handoff mantido |

---

## 1️⃣2️⃣ Timers, limites e configurações (Macro + EXECUTAR)

| # | Regra | Fonte | Status |
|---|---|---|---|
| T.1 | Re-executa captura de e-mails a cada **2 segundos** | macro 361-362 | 🚫 (Power Automate por gatilho/agenda) |
| T.2 | `IMPRESSAO_PAGA_GUIA` diário às **06:30** | macro 355-360 | 🟡 (agenda do fluxo) |
| T.3 | Limpa arquivos com **> 40 dias** | macro 215-230 | 🟡 (retenção configurável) |
| T.4 | Senha de desbloqueio de tela (kiosk) | EXECUTAR | 🚫 não aplicável |
| T.5 | E-mails de destino configurados em `EXECUTAR!K6/K8/K15` | EXECUTAR | 🟡 vira parâmetro |
| T.6 | Exclusão **manual** de notas canceladas (botão) | EXECUTAR | 🚫 ação humana |

---

## 🎯 Síntese — o que dá para implementar

| Bloco | Implementável agora (✅) | Com nuance (🟡) | Depende do time (⬜) | Não migra (🚫) |
|---|---|---|---|---|
| Filtros de entrada | F.1–F.8 | — | — | — |
| Colunas derivadas | D.3–D.13 | D.1, D.2 (SUB_LOC) | — | — |
| Limpeza | C.1–C.8 | — | — | — |
| PAGA_GUIA (cálculo) | §4 completo | — | — | — |
| Roteamento | matriz §5 | destino exceção | `STG.GUIA`/`CASE` | — |
| Nota mãe/agrupamento | M.1, M.4 | M.2, M.3 | — | — |
| Renomeação | R.1–R.3 | R.4 (páginas) | — | — |
| Anti-reimpressão | A.1–A.4 | — | — | — |
| Paga-guia | — | G.1, G.3 | G.5 (retorno) | G.2, G.4 |
| E-mails | — | E.1, E.4 | — | E.2, E.3, E.5 |
| Timers/config | — | T.2, T.3, T.5 | — | T.1, T.4, T.6 |

> **Pontos que exigem decisão/confirmação do time** estão consolidados em [03_Analyze/07_Open_Questions.md](../03_Analyze/07_Open_Questions.md). As 3 lacunas reais: (1) destino da **exceção** (pasta vs e-mail); (2) **sinal de guia liberada** no Oracle (retorno paga-guia); (3) tratamento dos **SUB_LOC `GUIA`/`CASE`**.

---

## 🔗 Referências

- [01_Define/04_Regras_Negocio.md](../01_Define/04_Regras_Negocio.md) — regras de negócio (resumo)
- [04_Improve/01_PowerBI/04_Fluxo_Classificacao_Analise.md](01_PowerBI/04_Fluxo_Classificacao_Analise.md) — matriz de roteamento
- [04_Improve/01_PowerBI/01_Dataset_Schema.md](01_PowerBI/01_Dataset_Schema.md) — colunas do dataset
- [03_Analyze/07_Open_Questions.md](../03_Analyze/07_Open_Questions.md) — dúvidas priorizadas

</details>
