# Padrão de código AUTVS

Fonte única: repositório `AUTVS/.github`, pasta `padroes/`. Cada repositório recebe uma cópia
em `docs/padrao-codigo.md` (sincronizada por `padroes/sincronizar-padroes.ps1`). **Não edite a
cópia**: edite aqui e sincronize.

Este documento vale para pessoas e para o Claude. Regras marcadas com **[CI]** são verificadas
automaticamente e barram o merge; as demais dependem de revisão.

## 1. Fluxo obrigatório de qualquer implementação

1. Implementar **com testes junto**: unitários + QA/automatizados (e verificação no app quando houver UI).
2. Rodar a suíte **completa** local antes de commit/push:
   - `autvs_app`: `npm run verifica` (typecheck + lint + todos os testes).
   - `autvs_api`: `dotnet test AutvsApi.slnx --artifacts-path <pasta temporária>`.
3. Abrir PR (nunca push direto na `main`), esperar o CI verde, revisão de outra pessoa, merge.
4. Depois do merge: `pull` local, remover worktrees, avisar quem tem clone remoto.

Nenhuma etapa é pulada por "ser pequeno". Bug corrigido = teste que reproduz o bug **antes** da correção.

## 2. Estilo e formatação [CI]

- Formatação automática: Prettier (TypeScript) e `dotnet format` + `.editorconfig` (C#).
  Ninguém discute estilo em revisão: a ferramenta decide.
- TypeScript em modo estrito (`strict: true`); proibido `any` explícito sem comentário justificando.
- C#: `nullable` habilitado; warnings novos não entram (ver `Directory.Build.props`).
- Código legado **não é reformatado em massa**: formate só o que você alterou, para não poluir o diff.

## 3. Nomes

- Siga o idioma que o repositório já usa para identificadores (hoje predominantemente português
  para termos de domínio: `leSessao`, `tabelasOrdenaveis`). **Não misture idiomas dentro do mesmo nome.**
- Texto exibido ao usuário (telas, mensagens de erro, e-mails): **português do Brasil**.
- TypeScript: `camelCase` (variáveis/funções), `PascalCase` (componentes/tipos), `UPPER_SNAKE` (constantes).
- C#: `PascalCase` (tipos, métodos, propriedades), `_camelCase` (campos privados), `I` + nome para interfaces.
- Nome diz a intenção. Sem abreviação obscura, sem `data`, `temp`, `x`, `obj`.

## 4. Estrutura

- Uma responsabilidade por arquivo, função e componente.
- Complexidade ciclomática de função ≤ 15 [CI via ESLint `complexity`]; função > ~50 linhas pede divisão.
- Máximo ~3 níveis de aninhamento; prefira retorno antecipado.
- Reutilize o que já é compartilhado (ex.: `MenuAcoes`, `ThOrd`, `MenuExportacao`) em vez de criar paralelo.
- Sem código morto, sem `TODO` sem dono e data.

## 5. Erros, validação e segurança

- Validar na **borda** (entrada da API e formulários); dentro do sistema, confiar nos tipos.
- Nunca engolir exceção em silêncio (`catch {}` vazio é proibido). Erro tratado = logado com contexto ou devolvido ao chamador.
- **Segredos nunca no código nem no git**: user-secrets / variáveis de ambiente / cofre. `.env` reais fora do repo.
- **Dados sigilosos** (CPF, certificados, tokens, senhas) nunca em log, mensagem de commit, PR ou issue.
- Oracle/WinThor: **somente leitura, sempre**. Escrita só no Postgres do AUTVS.
- Dependência nova: justificar no PR; `npm audit` / Dependabot sem vulnerabilidade alta ou crítica aberta [CI].

## 6. Banco de dados (Postgres)

- Toda mudança de schema é uma **migration numerada** (`00NN_descricao`). Migration já aplicada em produção **nunca é editada**; corrija com uma nova.
- Migration entra no PR junto com o código que a usa e com teste.

## 7. Testes

- Pirâmide: muitos unitários, alguns de integração, poucos de ponta a ponta/QA.
- Regras de negócio críticas (fiscal, cobrança, autenticação, multi-tenant) exigem teste próprio.
- Teste verifica **comportamento**, não só executa linha: cobertura é sinal, não meta global.
- Teste instável (flaky) é bug: corrigir ou remover no mesmo PR, nunca ignorar.

## 8. Git, commits e PRs

- Branches: `feature/*`, `bugfix/*`, `hotfix/*`. Um assunto por PR.
- Commit: `tipo: resumo no imperativo` em português (`feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `perf`, `ci`), com data/hora no corpo quando for marco de entrega.
- `git add` **específico** por arquivo; nunca `git add -A` (outras pessoas/ferramentas editam em paralelo).
- Sem dados sigilosos em commit/PR (ver §5).
- Autor não aprova o próprio PR. Áreas em `CODEOWNERS` exigem o dono.

## 9. Documentação e decisões

- Comentário explica o **porquê** (regra de negócio, armadilha, decisão); o **quê** o código já diz.
- Contratos públicos (rotas da API, tipos exportados) têm descrição curta.
- Decisão de arquitetura relevante vira uma nota curta (ADR) em `docs/decisoes/AAAA-MM-DD-titulo.md`: contexto, decisão, consequências.

## 10. Observabilidade

- Logs estruturados, com identificador de correlação; nível correto (`Error` só para falha real).
- Nunca logar corpo de requisição com dados sigilosos.

## 11. Regras específicas do Claude

- Ler o `CLAUDE.md` do repositório antes de agir; este padrão é importado por ele.
- Não relaxar teste, lint ou regra para "passar": corrigir a causa.
- Não terminar com pendência: commit + PR + CI + merge + limpeza, ou dizer explicitamente o que ficou.
- Antes de ação difícil de reverter ou visível a terceiros (push, merge, deploy, migration em produção), confirmar com a pessoa responsável.
