# Classificação da documentação

Este diretório separa documentação publicável de contexto interno do projeto.

## Publicável após revisão normal

- `docs/workflows/development-routine.md`
- `docs/workflows/unic-cass-wsl-installation.md`

Esses documentos devem usar `$HOME`, variáveis de ambiente e placeholders como `<NOME_DO_PROJETO>`. Não devem conter nomes pessoais, caminhos locais absolutos, credenciais, IPs privados ou informações de cliente.

## Uso interno

- `AGENTS.md`
- `docs/architecture/`
- `docs/references/`

Esses caminhos estão ignorados pelo Git enquanto não houver autorização de publicação. Mesmo internamente, evitar dados pessoais e credenciais. Informações de escopo, estado, responsabilidades, arquitetura e documentos de origem devem ser revisadas pelo gestor antes de qualquer divulgação.

## Checklist antes de publicar

- confirmar ausência de senhas, tokens, chaves e conteúdo de `.env`;
- substituir nomes de usuário e caminhos locais por variáveis;
- anonimizar responsáveis por função;
- verificar URLs, anexos e metadados;
- confirmar a classificação com o gestor;
- revisar `git diff --cached` antes do commit.
