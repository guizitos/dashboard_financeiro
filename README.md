#  G-Finance - Dashboard Financeiro

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.10.0-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.10.0-0175C2?logo=dart)
![License](https://img.shields.io/badge/license-MIT-green)

Um aplicativo moderno de controle financeiro pessoal desenvolvido em Flutter, com design Material 3 e animações fluidas.

[Funcionalidades](#-funcionalidades) • [Arquitetura](#-arquitetura) • [Instalação](#-instalação) • [Estrutura](#-estrutura-do-projeto) • [Tecnologias](#-tecnologias)

</div>

---

##  Sobre o Projeto

G-Finance é um aplicativo completo de gestão financeira pessoal que permite controlar receitas e despesas de forma intuitiva e visual. Com interface moderna, animações suaves e gráficos interativos, o app oferece uma experiência premium para gerenciamento de finanças.

### ✨ Destaques

- **🎨 Design Moderno**: Interface Material Design 3 com gradientes, sombras sutis e bordas arredondadas
- **🚀 Animações Fluidas**: Transições suaves entre telas, FAB animado com escala/rotação/fade
- **📊 Visualização de Dados**: Gráficos de pizza e linhas para análise de gastos
- **🎯 Categorização Inteligente**: 21 categorias pré-definidas com ícones e cores específicas
- **📅 Navegação Temporal**: Seleção fácil de mês/ano para análise de períodos
- **⌨️ Teclado Numérico**: Interface customizada para entrada rápida de valores
- **💾 Persistência Local**: Dados armazenados localmente com SQLite

---

## 📸 Screenshots

<div align="center">

### Dashboard Principal
<img src="screenshots/dashboard.jpeg" alt="Dashboard" width="250"/>

### Adicionar Receita
<img src="screenshots/add_receita.jpeg" alt="Adicionar Receita" width="250"/>

### Adicionar Despesa
<img src="screenshots/add_despesa.jpeg" alt="Adicionar Despesa" width="250"/>

### Transações Mensais
<img src="screenshots/monthly_transactions.jpeg" alt="Transações Mensais" width="250"/>

### Editar Transação
<img src="screenshots/edit_transaction.jpeg" alt="Editar Transação" width="250"/>

### Gráficos e Análises
<img src="screenshots/charts.jpeg" alt="Gráficos" width="250"/>

### Seletor de Ano
<img src="screenshots/month_selector.jpeg" alt="Seletor de Ano" width="250"/>

> **Nota**: Adicione suas capturas de tela na pasta `screenshots/` na raiz do projeto.

</div>

---

## 🎯 Funcionalidades

### Gestão de Transações
- ✅ Adicionar receitas e despesas com teclado numérico customizado
- ✅ Editar transações existentes (valor, data, categoria, tipo)
- ✅ Excluir transações com confirmação
- ✅ Filtrar transações por categoria
- ✅ Visualizar transações mensais agrupadas por dia

### Categorias
- ✅ **6 categorias de receitas**: Salário, Freelance, Investimentos, Vendas, Bonificação, Aluguel
- ✅ **15 categorias de despesas**: Alimentação, Transporte, Moradia, Saúde, Educação, Lazer, Compras, Contas, Streaming, Academia, Pet, Vestuário, Viagem, Presentes, Outros
- ✅ Ícones e cores personalizadas para cada categoria

### Visualizações
- ✅ Dashboard com cards de saldo, receitas e despesas
- ✅ Gráfico de pizza mostrando distribuição de despesas por categoria
- ✅ Gráfico de linhas mostrando evolução mensal (últimos 6 meses)
- ✅ Lista de transações com swipe para editar/deletar

### Navegação
- ✅ Seletor de mês horizontal com scroll
- ✅ Seletor de ano em modal com busca rápida
- ✅ Navegação por setas (mês anterior/próximo)
- ✅ Bottom navigation para acesso rápido

### Experiência do Usuário
- ✅ FAB expansível com animações de escala, fade e rotação
- ✅ Transições suaves entre telas (slide + fade)
- ✅ Feedback visual ao adicionar transações (SnackBar colorido)
- ✅ Dialog para edição de descrição (evita conflito de teclados)
- ✅ Data pré-selecionada conforme mês visualizado
- ✅ Validações de formulário com mensagens claras

---

## 🏗️ Arquitetura

O projeto segue uma **arquitetura em camadas** com padrão **BLoC** para gerenciamento de estado:

```
┌─────────────────────────────────────────┐
│            PRESENTATION                 │
│  (Screens, Widgets, Animations)         │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│          BUSINESS LOGIC                 │
│  (BLoCs: Transaction, Category,         │
│   Filter, Report)                       │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│            REPOSITORY                   │
│  (TransactionRepository,                │
│   CategoryRepository)                   │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│          DATA SOURCE                    │
│  (DBProvider - SQLite)                  │
└─────────────────────────────────────────┘
```

### Padrões Utilizados

- **BLoC (Business Logic Component)**: Separação clara entre UI e lógica de negócio
- **Repository Pattern**: Abstração do acesso aos dados
- **Singleton**: DBProvider para conexão única com banco de dados
- **Factory Pattern**: Criação de modelos a partir de Map/JSON
- **Observer Pattern**: BLoC streams para reatividade

---

## 📂 Estrutura do Projeto

```
lib/
├── main.dart                          # Entry point, inicialização
├── app.dart                           # Configuração MaterialApp, tema
│
├── blocs/                             # Gerenciamento de estado
│   ├── transaction/
│   │   ├── transaction_bloc.dart      # Lógica de transações
│   │   ├── transaction_event.dart     # Eventos (Add, Update, Delete, Load)
│   │   └── transaction_state.dart     # Estados (Loading, Loaded, Error)
│   ├── category/
│   │   ├── category_bloc.dart         # Lógica de categorias
│   │   ├── category_event.dart        # Eventos de categorias
│   │   └── category_state.dart        # Estados de categorias
│   ├── filter/
│   │   └── filter_bloc.dart           # Filtros de transações
│   └── report/
│       └── report_bloc.dart           # Relatórios e gráficos
│
├── data/
│   └── db_provider.dart               # Conexão SQLite, migrations, seed
│
├── models/
│   ├── transaction.dart               # Model de transação
│   └── category.dart                  # Model de categoria
│
├── repositories/
│   ├── transaction_repository.dart    # CRUD + queries transações
│   └── category_repository.dart       # CRUD categorias
│
├── screens/
│   ├── dashboard_screen.dart          # Tela principal
│   ├── quick_add_transaction_screen.dart  # Adicionar transação
│   └── monthly_transactions_screen.dart   # Lista mensal
│
├── widgets/
│   ├── empty_state.dart               # Widget estado vazio
│   └── transaction_item.dart          # Item de transação (lista)
│
└── utils/
    └── category_icons.dart            # Mapeamento ícones/cores
```

### Descrição dos Principais Arquivos

#### 📄 `main.dart`
- Ponto de entrada da aplicação
- Inicializa `TransactionRepository` e `CategoryRepository`
- Cria `MultiBlocProvider` injetando todos os BLoCs
- Dispara eventos iniciais (`LoadTransactions`, `LoadCategories`)

#### 📄 `app.dart`
- Configuração do `MaterialApp`
- Define tema Material 3 com `useMaterial3: true`
- Configura `ColorScheme` e `ThemeData`
- Define rota inicial (`DashboardScreen`)

#### 📄 `data/db_provider.dart`
```dart
class DBProvider {
  static final DBProvider db = DBProvider._();  // Singleton
  static Database? _database;
  
  // Métodos principais:
  - database: Inicializa/retorna conexão SQLite
  - onCreate: Cria tabelas + seed de 21 categorias
  - onUpgrade: Migrations (versão atual: 3)
}
```

**Tabelas:**
- `categories`: id, name, icon, color
- `transactions`: id, title, amount, date, categoryId, isExpense

#### 📄 `repositories/transaction_repository.dart`
```dart
class TransactionRepository {
  // Métodos CRUD:
  - addTransaction(TransactionModel)
  - updateTransaction(TransactionModel)
  - deleteTransaction(int id)
  - getAllTransactions()
  - getAllTransactionsWithCategory()  // JOIN com categorias
  - getTransactionsByMonth(month, year)
}
```

#### 📄 `blocs/transaction/transaction_bloc.dart`
```dart
// Eventos:
- LoadTransactions
- AddTransaction(TransactionModel)
- UpdateTransaction(TransactionModel)
- DeleteTransaction(int id)

// Estados:
- TransactionLoading
- TransactionLoaded(List<TransactionModel>)
- TransactionError(String message)
```

#### 📄 `screens/dashboard_screen.dart`
**Componentes principais:**
- **FAB Animado**: `AnimationController` + `ScaleTransition`, `FadeTransition`, `RotationTransition`
- **Seletores Mês/Ano**: `showModalBottomSheet` com ListView horizontal/vertical
- **Cards de Resumo**: Gradientes `LinearGradient`, sombras `BoxShadow`
- **Gráficos**: `PieChart` (fl_chart) com cores por categoria
- **Lista Transações**: `ListView.builder` com `Dismissible` para swipe actions

**Animações:**
```dart
_fabAnimationController = AnimationController(duration: 300ms)
_scaleAnimation = Tween(0→1).animate(elasticOut)
_rotationAnimation = Tween(0→0.125).animate(easeInOut)  // 45° rotação
```

#### 📄 `screens/quick_add_transaction_screen.dart`
**Características:**
- Header gradiente com `extendBodyBehindAppBar`
- Teclado numérico customizado (64px, borderRadius 16)
- Campo descrição read-only → abre dialog
- Dropdown categorias com `menuMaxHeight: 400`, ícones circulares
- Transição `SlideTransition` + `FadeTransition` (400ms)
- Feedback visual com `SnackBar` ao salvar

#### 📄 `screens/monthly_transactions_screen.dart`
**Funcionalidades:**
- Agrupamento por dia: `_groupByDay()` retorna `List<Map<String, dynamic>>`
- Cabeçalhos formatados: `_formatDayHeader()` com array weekDays português
- Cards gradientes para Receitas/Despesas
- Lista com cards `surfaceContainerHighest`, ícones 48x48

#### 📄 `utils/category_icons.dart`
```dart
class CategoryVisual {
  final IconData icon;
  final Color color;
}

CategoryVisual getCategoryVisual(String name, ColorScheme scheme) {
  // Retorna ícone + cor específica para cada categoria
  // Exemplos:
  - 'alimentação' → restaurant_rounded, Colors.orange
  - 'transporte' → directions_car_rounded, Colors.blueGrey
  - 'saúde' → medical_services_rounded, Colors.redAccent
  // ... 21 categorias mapeadas
}
```

---

## 🛠️ Tecnologias

### Core
- **Flutter 3.10.0**: Framework UI multiplataforma
- **Dart 3.10.0**: Linguagem de programação

### State Management
- **flutter_bloc 8.1.3**: Implementação BLoC pattern
- **bloc 8.1.0**: Core BLoC library

### Persistência
- **sqflite 2.2.8**: SQLite database local
- **path_provider 2.0.15**: Acesso a diretórios do sistema
- **path 1.9.1**: Manipulação de caminhos

### Visualização de Dados
- **fl_chart 1.1.1**: Gráficos de pizza e linhas
- **syncfusion_flutter_charts 31.2.10**: Gráficos avançados
- **flutter_echarts 2.5.0**: Biblioteca de gráficos interativos

### Utilities
- **intl 0.20.2**: Internacionalização, formatação de datas/moedas
- **csv 5.0.0**: Exportação CSV
- **share_plus 9.0.0**: Compartilhamento de arquivos
- **url_launcher 6.3.2**: Abertura de URLs

### UI/UX
- **google_fonts 6.3.2**: Fontes customizadas
- **Material Design 3**: Sistema de design com ColorScheme

---

## 🚀 Instalação

### Pré-requisitos
- Flutter SDK 3.10.0 ou superior
- Dart SDK 3.10.0 ou superior
- Android Studio / VS Code
- Emulador Android/iOS ou dispositivo físico

### Passos

1. **Clone o repositório**
```bash
git clone https://github.com/seu-usuario/dashboard_financeiro.git
cd dashboard_financeiro
```

2. **Instale as dependências**
```bash
flutter pub get
```

3. **Execute o app**
```bash
# Windows
flutter run -d windows

# Android
flutter run -d <device_id>

# iOS (apenas macOS)
flutter run -d ios
```

4. **Build para produção**
```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# Windows
flutter build windows --release
```

---

## 📊 Fluxo de Dados

### Adicionar Transação

```
┌─────────────────────────────────────────────────────────────┐
│ 1. Usuário preenche formulário (valor, descrição, etc.)    │
└────────────────────┬────────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────────┐
│ 2. _save() → context.read<TransactionBloc>()                │
│              .add(AddTransaction(tx))                       │
└────────────────────┬────────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────────┐
│ 3. TransactionBloc recebe evento                            │
│    → emit(TransactionLoading())                             │
└────────────────────┬────────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────────┐
│ 4. Bloc chama repository.addTransaction(tx)                 │
└────────────────────┬────────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────────┐
│ 5. Repository executa INSERT no SQLite                      │
└────────────────────┬────────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────────┐
│ 6. Repository retorna lista atualizada                      │
└────────────────────┬────────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────────┐
│ 7. Bloc → emit(TransactionLoaded(transactions))             │
└────────────────────┬────────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────────┐
│ 8. UI (BlocBuilder) reconstrói com novos dados              │
│    Dashboard atualiza saldo, gráficos, lista                │
└─────────────────────────────────────────────────────────────┘
```

---

## 🎨 Design System

### Cores

O app usa **Material Design 3 ColorScheme** com variações:

- **Primary**: Azul principal (receitas)
- **Error**: Vermelho (despesas)
- **Tertiary**: Roxo (saldo)
- **Surface**: Fundo de cards
- **SurfaceContainerHighest**: Cards elevados
- **SurfaceContainerLowest**: Background geral

### Tipografia

- **Títulos**: fontSize 18-20, fontWeight.bold
- **Subtítulos**: fontSize 14-16, fontWeight.w600
- **Corpo**: fontSize 12-14, fontWeight.normal
- **Display (valores)**: fontSize 56, fontWeight.bold, letterSpacing -2

### Espaçamento

- **Padding padrão**: 16px (cards), 24px (telas)
- **Margin entre cards**: 8-12px
- **BorderRadius**: 16-20px (cards), 32px (headers)

### Animações

- **Duração padrão**: 300-400ms
- **Curvas**: `easeInOutCubic`, `elasticOut`
- **Transições**: Slide + Fade, Scale + Fade

---

## 🔒 Segurança e Boas Práticas

- ✅ **Singleton Pattern** para conexão DB (evita múltiplas conexões)
- ✅ **Validação de formulários** antes de salvar
- ✅ **Confirmação de exclusão** com AlertDialog
- ✅ **Dispose correto** de controllers e streams
- ✅ **Tratamento de erros** com try-catch e estados de erro
- ✅ **Migrations versionadas** para evolução do schema
- ✅ **Separação de concerns** (UI, lógica, dados)

---

## 📝 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

---

## 👨‍💻 Desenvolvedor

Desenvolvido com 💙 usando Flutter

---

## 🤝 Contribuindo

Contribuições são bem-vindas! Sinta-se à vontade para:

1. Fazer um fork do projeto
2. Criar uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add: nova funcionalidade'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abrir um Pull Request

---

## 📧 Contato

Para dúvidas ou sugestões, abra uma [issue](https://github.com/seu-usuario/dashboard_financeiro/issues) no repositório.

---

<div align="center">

**[⬆ Voltar ao topo](#-g-finance---dashboard-financeiro)**

</div>
