# PDI

PDI é um workspace calmo para transformar planos de desenvolvimento pessoal em objetivos, tarefas e reflexões. A aplicação é um monólito Rails 8.1 com SQLite, Inertia e React.

## Requisitos

- Ruby 3.4.5
- Bundler
- Node.js e npm
- SQLite 3

## Setup

```bash
bin/setup
npm install
bin/rails db:prepare
```

Inicie o ambiente completo (Rails, Vite e worker da fila) com:

```bash
bin/dev
```

Ou rode os processos separadamente:

```bash
bin/rails server
bin/vite dev
bin/jobs
```

O Vite atende em desenvolvimento e o Solid Queue processa os relatórios XLSX de forma durável. Em produção, configure o `RAILS_MASTER_KEY`, persista `storage/` e execute `bin/jobs` junto do servidor.

## Verificação

```bash
bin/rails test
npm run build
bin/rubocop
bin/brakeman --no-pager
bin/bundler-audit
```

O pipeline de CI executa segurança, lint, testes Rails e system tests. O build Vite é executado localmente por `npm run build`; a imagem Docker também compila os assets durante o build.

## Produto

- Usuários podem criar conta, entrar, sair e recuperar senha.
- Cada usuário pode manter vários planos, cada um com título, propósito, datas e status.
- Dentro do plano há objetivos e tarefas; tarefas podem ser concluídas ou reabertas.
- Progresso é derivado da proporção de tarefas concluídas. Um plano sem tarefas mostra 0%.
- Cada conclusão nova registra 25 XP. Reabrir registra -25 XP. O evento de XP é imutável, recebe um identificador único e uma assinatura HMAC baseada no segredo da aplicação. Assim, concluir/reabrir repetidamente não cria XP líquido e não permite editar ou apagar o histórico.
- O nível sugerido é `floor(XP total / 100) + 1`.
- Check-ins guardam uma reflexão curta por plano.
- A exportação gera um XLSX assíncrono com abas de visão geral, objetivos, tarefas, XP e check-ins. O download exige que o export pertença ao usuário autenticado e esteja pronto.

## Decisões e limitações da V1

- Não há colaboração, notificações, anexos, metas numéricas ou edição de tarefas: o escopo da V1 mantém a unidade de trabalho simples.
- A assinatura protege integridade contra alterações pela aplicação, mas não é uma auditoria externa nem substitui backups do banco.
- Exports ficam em `storage/exports` local. Em múltiplas instâncias, use armazenamento compartilhado ou adapte `ExportPlanJob`.
- SQLite é adequado para a V1 local e de pequeno porte. O banco de fila é separado em desenvolvimento/produção para o Solid Queue.
- O frontend usa Inertia sem uma API pública separada; autenticação continua usando sessões Rails.
