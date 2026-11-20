## O que muda e por quê

<!-- Descreva a mudança e o motivo. Sem dados sigilosos (CPF, tokens, certificados, senhas). -->

## Tipo

- [ ] Feature
- [ ] Correção de bug (inclui teste que reproduz o bug)
- [ ] Refatoração
- [ ] Documentação
- [ ] Banco de dados (migration numerada)

## Checklist (obrigatório)

- [ ] Testes novos/atualizados: unitários + QA/automatizados
- [ ] Suíte **completa** rodou local (`npm run verifica` / `dotnet test`) e passou
- [ ] CI verde
- [ ] Sem segredo, `.env` ou dado sigiloso no diff, na descrição ou nos commits
- [ ] Migration nova é numerada e nenhuma migration já aplicada foi editada
- [ ] Oracle/WinThor continua somente leitura
- [ ] Documentação/`CLAUDE.md` atualizados quando a regra ou o comportamento mudou
- [ ] Verifiquei a tela no app (quando há UI), em tema claro e escuro
