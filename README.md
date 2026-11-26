# Ivani Mello Studio — Aplicativo Flutter

Aplicativo desenvolvido em Flutter e Dart para gerenciamento de agendamentos do **Ivani Mello Studio de Beleza**, integrado à API REST desenvolvida com NestJS.

O projeto faz parte do sistema de gerenciamento do salão, permitindo que a administradora consulte, cadastre, edite e exclua agendamentos diretamente pelo aplicativo.

## Sobre o projeto

O aplicativo foi desenvolvido com o objetivo de facilitar o gerenciamento dos atendimentos do salão, oferecendo uma interface simples e intuitiva para a administração da agenda.

A aplicação utiliza uma API REST para realizar a comunicação com o backend, permitindo que os dados sejam compartilhados com o sistema web do Ivani Mello Studio.

O acesso é restrito à administradora, utilizando autenticação por e-mail, senha e token JWT.

## Funcionalidades

### Autenticação
- Login utilizando e-mail e senha.
- Validação das credenciais através da API.
- Controle de acesso para usuários com perfil ADMIN.
- Autenticação utilizando JWT.
- Armazenamento local do token de autenticação.
- Recuperação automática da sessão ao atualizar o aplicativo.
- Logout com confirmação e encerramento da sessão.

### Agendamentos
- Listagem dos agendamentos cadastrados.
- Consulta dos dados diretamente pela API.
- Organização dos atendimentos por data e horário.
- Agrupamento dos agendamentos por dia.
- Filtro por status:
  - Agendado.
  - Confirmado.
  - Concluído.
  - Cancelado.
- Filtro por data específica.
- Limpeza dos filtros aplicados.
- Cadastro de novos agendamentos.
- Edição de agendamentos existentes.
- Exclusão com confirmação.
- Atualização dos dados após as operações.

### Clientes e procedimentos
- Consulta dos clientes cadastrados no sistema.
- Consulta dos procedimentos cadastrados no sistema.
- Seleção de clientes existentes ao criar um agendamento.
- Seleção de procedimentos existentes ao criar um agendamento.
- Utilização dos identificadores dos registros para relacionamentos com o backend.

**Observação:** o aplicativo não realiza o cadastro de clientes ou procedimentos. Esses registros são previamente cadastrados pelo sistema administrativo web e posteriormente selecionados no aplicativo.

### Interface
- Identidade visual do Ivani Mello Studio.
- Logo do salão na tela de login e na tela inicial.
- Interface desenvolvida com Material Design.
- Formulários com validação.
- Indicadores de carregamento.
- Mensagens de sucesso e erro.
- Interface adaptável para diferentes tamanhos de tela.

## Tecnologias utilizadas

| Tecnologia | Utilização |
|---|---|
| Flutter | Framework utilizado para desenvolver a interface do aplicativo. |
| Dart | Linguagem de programação utilizada no desenvolvimento. |
| Material UI | Componentes visuais e elementos de interface. |
| HTTP | Realização de requisições à API REST. |
| Shared Preferences | Armazenamento local do token de autenticação. |
| JWT | Autenticação e autorização de acesso. |
| JSON | Formato utilizado na comunicação entre aplicativo e API. |

## Arquitetura do projeto

O aplicativo utiliza uma organização baseada na separação entre telas, modelos de dados e serviços de comunicação com a API.

### Estrutura de pastas

```text
lib/
│
├── api/
│   ├── api_service.dart
│   └── auth_service.dart
│
├── model/
│   ├── agendamentos.dart
│   ├── cliente.dart
│   └── procedimento.dart
│
├── telas/
│   ├── home.dart
│   ├── login.dart
│   └── agendamentos.dart
│
└── main.dart

assets/
│
└── images/
    └── logo.png

pubspec.yaml
```

### Responsabilidade dos arquivos

**main.dart**

Responsável pela inicialização do aplicativo, configuração do tema, localização e verificação da sessão armazenada antes de apresentar a tela inicial ou a tela de login.

**api/api_service.dart**

Responsável pela comunicação HTTP com o backend. Contém os métodos GET, POST, PATCH e DELETE, além dos métodos específicos para consultar clientes, procedimentos e agendamentos.

**api/auth_service.dart**

Responsável pelo processo de autenticação, armazenamento e recuperação do token JWT e encerramento da sessão.

**model/agendamentos.dart**

Representa os dados dos agendamentos, incluindo identificadores de clientes e procedimentos, data, horário, status e observações.

**model/cliente.dart**

Representa os dados dos clientes retornados pela API.

**model/procedimento.dart**

Representa os procedimentos cadastrados, incluindo nome, descrição, preço e duração.

**telas/login.dart**

Apresenta o formulário de autenticação, realiza a validação dos campos e permite o acesso à área administrativa.

**telas/home.dart**

Apresenta a tela inicial do aplicativo, a identidade visual do salão, o acesso à agenda e a opção de logout.

**telas/agendamentos.dart**

Contém a interface de gerenciamento dos agendamentos, incluindo listagem, filtros, formulários de cadastro e edição e exclusão de registros.

**assets/images/logo.png**

Armazena a identidade visual utilizada nas telas do aplicativo.

## Comunicação com o backend

O aplicativo realiza requisições HTTP para a API desenvolvida com NestJS.

Durante o desenvolvimento local, foram utilizados os seguintes endereços:

| Serviço | Endereço |
|---|---|
| Aplicativo Flutter Web | http://localhost:5000 |
| Backend NestJS | http://localhost:3000 |
| API REST | http://localhost:3000/api |

### Principais rotas utilizadas

| Método HTTP | Rota | Funcionalidade |
|---|---|---|
| POST | `/api/auth/login` | Realizar autenticação. |
| GET | `/api/clientes` | Consultar clientes. |
| GET | `/api/procedimentos` | Consultar procedimentos. |
| GET | `/api/agendamentos` | Listar agendamentos. |
| POST | `/api/agendamentos` | Cadastrar agendamento. |
| PATCH | `/api/agendamentos/:id` | Atualizar agendamento. |
| DELETE | `/api/agendamentos/:id` | Excluir agendamento. |

As rotas administrativas protegidas utilizam o token JWT no cabeçalho das requisições:

```http
Authorization: Bearer TOKEN_JWT
```

### Funcionamento da autenticação

1. A administradora informa seu e-mail e senha.
2. O aplicativo envia as credenciais para a rota de autenticação.
3. O backend verifica as credenciais.
4. Caso estejam corretas e o usuário possua perfil ADMIN, o backend retorna o token JWT.
5. O aplicativo armazena o token utilizando Shared Preferences.
6. Nas requisições seguintes, o token é enviado no cabeçalho HTTP.
7. Ao atualizar o aplicativo, a sessão é recuperada automaticamente.
8. Ao realizar logout, o token é removido do armazenamento local.

## Banco de dados

O aplicativo não realiza acesso direto ao banco de dados.

Todas as operações são realizadas através da API NestJS, que utiliza Prisma ORM para acessar o banco de dados SQLite.

As principais entidades utilizadas são:

- **Cliente:** informações dos clientes cadastrados.
- **Procedimento:** serviços oferecidos pelo salão.
- **Agendamento:** registro dos atendimentos, relacionado a um cliente e a um procedimento.

Dessa maneira, o aplicativo Flutter e o sistema web trabalham com os mesmos registros armazenados no backend.

## Como executar o projeto

### Pré-requisitos

Antes de executar o aplicativo, é necessário ter instalado:

- Flutter SDK.
- Dart SDK (incluído na instalação do Flutter).
- Visual Studio Code.
- Extensões Flutter e Dart para o VS Code.
- Git.
- Node.js e npm para executar o backend.

### 1. Clonar o repositório

```bash
git clone URL_DO_REPOSITORIO
```

Entre na pasta do projeto:

```bash
cd ivani_mello_app
```

### 2. Instalar as dependências

Execute:

```bash
flutter pub get
```

### 3. Configurar a API

No arquivo:

```text
lib/api/api_service.dart
```

Configure o endereço do backend:

```dart
static const String baseUrl = 'http://localhost:3000/api';
```

O endereço deve ser ajustado conforme o ambiente de execução. Para dispositivos físicos ou emuladores, `localhost` pode precisar ser substituído pelo endereço acessível do computador ou servidor.

### 4. Iniciar o backend

O backend NestJS deve estar configurado e em execução na porta 3000, com o banco de dados preparado.

### 5. Executar o aplicativo

Para executar no Microsoft Edge:

```bash
flutter run -d edge --web-port 5000
```

O aplicativo ficará disponível em:

```text
http://localhost:5000
```

Também é possível executar em dispositivos e emuladores compatíveis com Flutter, respeitando as configurações de rede e plataforma.

## Testes e validações

Durante o desenvolvimento foram realizados testes para verificar:

- Inicialização e execução do aplicativo.
- Autenticação com credenciais válidas e inválidas.
- Restrição de acesso para usuários sem perfil ADMIN.
- Persistência da sessão após atualizar a página.
- Recuperação do token armazenado.
- Consulta de clientes e procedimentos.
- Listagem dos agendamentos.
- Cadastro de novos agendamentos.
- Edição de agendamentos existentes.
- Alteração de status.
- Exclusão de agendamentos.
- Aplicação dos filtros por data e status.
- Encerramento da sessão através do logout.
- Verificação estática do código utilizando `flutter analyze`.

## Objetivo do projeto

O aplicativo Ivani Mello Studio tem como objetivo complementar o sistema web de gerenciamento do salão, proporcionando uma alternativa de acesso às funcionalidades de agendamento por meio de uma interface desenvolvida com Flutter.

O projeto permite centralizar as informações dos atendimentos, facilitar a organização da agenda e manter a integração com os dados já existentes no sistema web.

## Desenvolvedores

Projeto acadêmico desenvolvido como parte dos estudos de desenvolvimento de aplicações móveis utilizando Flutter e Dart.

**Projeto:** Ivani Mello Studio de Beleza  
**Aplicação:** Flutter  
**Backend:** NestJS  
**Banco de dados:** SQLite