## Padrão de código AUTVS (obrigatório)

@docs/padrao-codigo.md

Resumo: toda implementação traz testes (unitários + QA/automatizados) e roda a suíte completa
(`npm run verifica` ou `dotnet test`) **antes** de commit, PR e merge. PR com CI verde e revisão de
outra pessoa. Segredos e dados sigilosos nunca no código/commit/PR. Oracle somente leitura.
