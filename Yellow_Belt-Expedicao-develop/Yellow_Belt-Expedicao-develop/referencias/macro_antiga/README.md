# Macro Antiga

> **Revisão documental: 2026-10-14.** Referência histórica para engenharia reversa, não rotina da ferramenta atual. As instruções antigas de depósito abaixo não autorizam versionar binários ou dados reais.

Não comitar macro/planilha com CNPJ, chaves, credenciais ou tokens. Usar export textual sanitizado e amostras anonimizadas aprovadas; segredos devem permanecer no mecanismo corporativo seguro, nunca em documentação/chamado. Regras atuais e diferenças estão no [Mapa de Regras](../../04_Improve/07_Mapa_de_Regras.md). Presença de arquivo legado não comprova equivalência integral ao modelo.

Pasta destinada ao arquivo `.xlsm` (ou equivalente) da macro que gerava os PDFs classificados das NFs antes da atualização do SYNCHRO quebrar a integração.

## O que colocar aqui

- O arquivo da macro completo (`.xlsm`, `.xls`, `.xlam`, `.xlsb`).
- Planilhas auxiliares lidas pela macro (listas de CFOPs, transportadoras, parâmetros).
- Em `codigo/`: os módulos VBA exportados (`.bas`, `.cls`, `.frm`) — facilita versionamento e revisão.

## Antes de comitar

Verificar se há **credenciais, tokens ou URLs com senha** hardcoded no VBA. Comum em macros antigas. Se encontrar:

1. Não comitar a versão com credencial.
2. Substituir por placeholder (`<TOKEN>`, `<SENHA>`) na versão comitada.
3. Anotar separadamente (fora do repo) o valor real, se necessário para reconstrução.

## Como exportar o VBA

Dentro do Excel:
1. `Alt + F11` abre o editor VBA.
2. Em cada módulo / classe → botão direito → **Export File** → salva em `codigo/`.

Alternativa via linha de comando: usar `olevba` (parte da `oletools`) para despejar tudo de uma vez.

## Próximos passos

Após depositar a macro aqui:
1. Avisar para iniciar engenharia reversa.
2. Saída esperada: mapa de regras de negócio, integração SYNCHRO, listas hardcoded, lógica de ordenação — cruzados com `Analise_Queries.md` e `07_Open_Questions.md`.
