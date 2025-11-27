<!-- Instruções direcionadas a agentes AI: focar em padrões reais detectáveis neste repositório -->
# Copilot Instructions (project-specific)

Breve: Este repositório é um app Flutter estruturado em `lib/` com camadas claras: *data* (persistência), *repositories*, *models*, *blocs*, *screens* e *widgets*. Priorize mudanças locais e preserve contratos de DB e formatos de dados.

**Arquitetura**
- **Data / DB**: `lib/data/db_provider.dart` contém a criação do banco SQLite (sqflite). A DB é aberta via `DBProvider.db.database` e o arquivo é criado em `getDatabasesPath()` com nome `dashboard_financeiro.db`.
- **Repository**: `lib/repositories/transaction_repository.dart` expõe CRUD e consultas (ex.: `getAllTransactionsWithCategory()` retorna `List<Map<String,dynamic>>` com o alias `categoryName`). Alterações na forma das queries exigem atualização nas camadas que consomem esses campos.
- **Models**: `lib/models/transaction.dart` e `lib/models/category.dart` definem a serialização (`toMap()` / `fromMap()`). Observação: `TransactionModel.date` é armazenado como ISO string; `isExpense` é saved as `1`/`0`.
- **State**: O app usa `flutter_bloc`. `lib/main.dart` cria `TransactionRepository()` e injeta `TransactionBloc`, `CategoryBloc`, `FilterBloc`, `ReportBloc` via `MultiBlocProvider` e dispara eventos como `LoadTransactions()` / `LoadCategories()`.

**Fluxos críticos e comandos**
- Instalar dependências: `flutter pub get`
- Analisar: `flutter analyze`
- Testes: `flutter test` (rodar `test/widget_test.dart`)
- Rodar (ex.: Windows): `flutter run -d windows` ou `flutter run -d <device>`
- Android build (opcional): `cd android; .\gradlew.bat assembleDebug`

Nota operacional: o projeto usa `sqflite` (mobile). Tentar rodar a versão web sem adaptar a persistência causará erros (sqflite não é compatível com web). Para testes rápidos, use emulador/simulador ou `flutter run` em dispositivo móvel/desktop.

**Padrões do projeto (detectáveis)**
- Arquivos e responsabilidades: `lib/data/*` = acesso cru ao DB; `lib/repositories/*` = interface de alto nível para CRUD e queries compostas; `lib/blocs/*` = lógica de estado; `lib/screens/*` = UI que consome Blocs/repositories via eventos/selectors; `lib/widgets/*` = componentes reutilizáveis.
- Serialização consistente: datas usam `toIso8601String()` e `DateTime.parse(...)` na desserialização — preserve esse formato quando alterar `TransactionModel`.
- Booleans persistidos como inteiros: `isExpense` → `1`/`0`. Mudanças aqui precisam de migração/compatibilidade.
- Queries SQL cru: `getAllTransactionsWithCategory()` usa `LEFT JOIN` e retorna `categoryName` — front-end espera esta chave.

**Quando mudar o DB**
- Se modificar esquema (colunas/tipos): aumente `version` do DB ou remova manualmente o DB em `getDatabasesPath()` para desenvolvimento. Não suponha migrações automáticas; atualmente não há lógica de migração.
- Arquivo relevante: `lib/data/db_provider.dart` (criação de tabelas e seed de categorias).

**Exemplos práticos**
- Inicialização: veja `lib/main.dart` — novos repositórios devem expor `init()` quando exigirem setup assíncrono antes do `runApp()`.
- Consumir consulta com categoria: `transactionRepository.getAllTransactionsWithCategory()` retorna mapas com `categoryName` que devem ser usados por widgets/listagens.
- Widget que consome model: `lib/widgets/transaction_item.dart` recebe `TransactionModel` e `CategoryModel` já carregados — não faz fetchs adicionais.

**Dependências e limitações conhecidas**
- `sqflite`, `path_provider` — mobile/desktop local DB.
- Visualização: `fl_chart`, `syncfusion_flutter_charts`, `flutter_echarts` usadas para gráficos.
- Compatibilidade web: `sqflite` não funciona; adaptar ou mockar persistência ao adicionar suporte web.

**Guidelines para um agente AI**
- Preserve contratos do DB e nomes de coluna. Exemplos: `date` é ISO string, `isExpense` é 1/0, `categoryName` é um alias na query.
- Antes de alterar a inicialização do app, verifique `lib/main.dart` e garanta que `TransactionRepository.init()` (ou equivalente) seja chamado quando necessário.
- Ao alterar consultas SQL, atualize consumidores que esperam campos específicos (ex.: `categoryName`).
- Para mudanças que impactam múltiplas camadas, crie pequenas PRs focadas: (1) adaptar model/serialização, (2) atualizar repository/queries, (3) ajustar bloc/screens/widgets.

Se algo aqui estiver incompleto ou se você quer que eu acrescente exemplos de PRs, comandos de CI, ou detalhes de debugging (ex.: como limpar DB local), diga e eu ajusto.

*** Fim das instruções específicas do repositório ***
