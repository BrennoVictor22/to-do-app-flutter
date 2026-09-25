# BUILD_LOG

## Entrada 1

### Solicitação/Requisição

"Desenvolver um aplicativo móvel de lista de tarefas com persistência em SQLite, múltiplas telas, categorias, filtragem, vencimentos opcionais e notificações locais agendadas."

### Resumo da Decisão

Decidi inicializar um projeto Flutter nativo com arquitetura simples baseada em Repository + Estado local em memória, usando SQLite para persistência e `flutter_local_notifications` para lembretes. Vou usar `sqflite` para armazenar tarefas e categorias e `go_router` para navegação entre as telas. A estrutura será pequena e direta, com modelos, repositórios e views, sem adicionar complexidade desnecessária.

### Ações Executadas

- Criado este arquivo de log de desenvolvimento.
- Preparado a criação do projeto Flutter no diretório atual.
- Ainda aguardando a verificação da instalação do SDK e da criação do app.

### Resultado

- Arquivo de log criado.
- Projeto ainda não inicializado.

### Problemas/Erros

- Nenhum ainda.

### Tentativas de Correção

- Nenhuma ainda.

### Status Atual

- Parcialmente concluído

## Entrada 2

### Solicitação/Requisição

"Implementar a aplicação completa de tarefas com SQLite, múltiplas telas, categorias, filtros, data de vencimento e notificações locais."

### Resumo da Decisão

Escolhi uma estrutura simples em Flutter com `provider` para gerenciamento de estado, um único serviço de banco de dados SQLite e um serviço de notificações locais. As tarefas e categorias serão persistidas em tabelas dedicadas; a exclusão de categoria será tratada como `SET NULL` nas tarefas, preservando os dados sem categoria. A navegação será direta por `Navigator.push` entre as telas, passando o objeto da tarefa quando necessário.

### Ações Executadas

- Inicializado o projeto Flutter no diretório do workspace.
- Criadas as pastas principais de modelos, serviços, estado e telas.
- Definidos os modelos de `Task` e `Category`.
- Implementado o banco SQLite com tabelas de tarefas e categorias.
- Configurado o `provider` para estado da lista de tarefas e filtros.
- Implementado o serviço de notificações locais com solicitação de permissão para Android.
- Criadas as telas de listagem, edição de tarefa e gerenciamento de categorias.
- Adicionadas dependências principais no `pubspec.yaml`.
- Criado teste de smoke para a tela inicial.

### Resultado

- A base do aplicativo ficou estruturada e pronta para expansão.
- O fluxo principal de tarefas, categorias e filtros foi implementado em código.

### Problemas/Erros

- O ambiente atual não possui o comando `flutter` disponível no PATH, então a verificação final de compilação não pôde ser executada nesta sessão.
- A instalação do Flutter SDK foi concluída manualmente em `C:\src\flutter`, mas o ambiente de execução do editor não está configurado para uso imediato do comando.

### Tentativas de Correção

- Busquei e localizei a instalação do SDK em `C:\src\flutter`.
- Ajustei a inicialização do app para manter a lógica do `TaskStore` e a navegação consistentes.

### Status Atual

- Parcialmente concluído

### Dependências principais

- `sqflite`: persistência local em SQLite.
- `provider`: gerenciamento de estado simples e reativo.
- `flutter_local_notifications`: notificações locais agendadas.
- `permission_handler`: solicitação segura de autorização de notificação.
- `timezone`: agendamento de notificações em horário local.
- `intl`: formatação de datas e horários.
- `path`: resolução de caminhos para o banco.

## Entrada 3

### Solicitação/Requisição

"Validar a execução da aplicação em um dispositivo suportado e verificar se a persistência e as telas funcionam corretamente."

### Resumo da Decisão

A aplicação foi gerada para `web` e `windows`, mas a implementação de persistência usa `sqflite`, que é uma biblioteca nativa para SQLite não compatível com execução em navegador web. Como este projeto exige SQLite local e notificações nativas, a validação apropriada é em ambiente nativo (Android/iOS/emulador) ou Windows desktop com Visual Studio instalado. Para web, a solução exigiria uma camada de banco diferente, como IndexedDB ou outra implementação web-compatible.

### Ações Executadas

- Gerados os arquivos de plataforma com `flutter create . --platforms=web,windows`.
- Executado `flutter run -d chrome` para verificar o comportamento em navegador.
- Confirmado que a execução no Chrome falha pela inicialização do SQLite em ambiente web.
- Verificado o diagnóstico do Flutter para detectar plataformas disponíveis e dependências nativas.

### Resultado

- O projeto é reconhecido e o teste de widget passou com sucesso.
- O navegador Chrome não pode executar a funcionalidade de SQLite atual porque `sqflite` requer ambiente nativo.
- A validação real do app deve ocorrer em dispositivo móvel/emulador nativo ou em Windows desktop com suporte do SDK do Visual Studio.

### Problemas/Erros

- `Bad state: databaseFactory not initialized` ao rodar em Chrome.
- `Visual Studio` não instalado, ignorando a build nativa para Windows.
- Android toolchain incompleto no ambiente atual (SDK/CLI do Android ausentes).

### Tentativas de Correção

- Gerado suporte de plataforma para web/windows.
- Tentativa de execução em Chrome para validar a interface.
- Diagnóstico do Flutter confirmou que os problemas são de ambiente nativo e não de compilação Dart em si.

### Status Atual

- Parcialmente concluído
- Necessita de execução em ambiente nativo para validação completa

## Entrada 4

### Solicitação/Requisição

"Ignorar web/windows e manter o projeto focado em Android Studio com o mínimo essencial para execução nativa no Android. Remover pastas e arquivos não necessários e atualizar o histórico de desenvolvimento."

### Resumo da Decisão

Decidi manter o projeto apenas com o escopo Android nativo. O suporte para web/windows foi removido porque a aplicação exige SQLite local e notificações do sistema, que funcionam em ambiente nativo e não no navegador. Portanto, o foco agora é um projeto Flutter com estrutura mínima, mantendo os arquivos de código da aplicação, os testes e o suporte nativo do Android gerado pelo Flutter.

### Ações Executadas

- Removidas as pastas `web` e `windows` geradas anteriormente.
- Removido o código e artefatos extras que não fazem parte do fluxo Android nativo.
- Recriado o suporte mínimo de plataforma com `flutter create . --platforms=android`.
- Mantido o projeto com a estrutura base necessária para Flutter + Android.
- Atualizado este arquivo de log de desenvolvimento.

### Resultado

- O projeto foi reduzido ao escopo Android.
- O ambiente ficou alinhado com os requisitos do app: SQLite local, notificações nativas e execução em Android Studio.

### Problemas/Erros

- O ambiente local ainda precisa de dispositivo ou emulador Android para execução real.
- A validação em Chrome não é adequada para esta aplicação e foi descartada.

### Tentativas de Correção

- Removido suporte de web/windows.
- Regerado somente a plataforma Android.
- Mantido a estrutura de código e testes para validar a compilação nativa.

### Status Atual

- Concluído para o escopo Android
- Aguardando validação final em emulador ou dispositivo Android

## Entrada 5

### Solicitação/Requisição

"Corrigir falha de build do Android após habilitar desugaring para o plugin de notificações locais."

### Resumo da Decisão

O erro de compilação do Android foi causado por um bloco antigo de configuração `kotlinOptions` no Gradle, que é obsoleto com a versão atual do Android Gradle Plugin. Como o projeto já usa `compilerOptions` em Kotlin e o plugin de notificações local exige Java 8 desugaring, a correção foi manter apenas a configuração necessária de desugaring e remover a opção redundante e depreciada.

### Ações Executadas

- Ajustado o arquivo `android/app/build.gradle.kts` para manter o `coreLibraryDesugaring` e remover a configuração obsoleta `kotlinOptions`.
- Revalidado a compilação do projeto em ambiente Android.

### Resultado

- O build do Android foi ajustado para a sintaxe atual do AGP.
- O projeto está preparado para a compilação nativa Android sem erro de configuração do plugin.

### Problemas/Erros

- Falha de build por obrigatoriedade de `coreLibraryDesugaring` e bloqueio de configuração antiga do Kotlin DSL.

### Tentativas de Correção

- Habilitação de desugaring.
- Remoção da configuração depreciada do Kotlin DSL.

### Status Atual

- Concluído
