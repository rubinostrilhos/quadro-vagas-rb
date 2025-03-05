# Quadro de Vagas

Está uma aplicação Open Source desenvolvida pelo time da Campus Code e os formandos da turma 13 do TreinaDev.

## Setup

### Organização

Você terá acesso aos arquivos de desenvolvimento em ambiente Docker na seguinte estrura de pastas:

```
.
└── quadro_vagas_rb/
    ├── [...]
    ├── bin/
    │   └── setup_app.sh
    ├── docker/
    │   ├── bash_aliases.sh
    │   └── development/
    │       ├── Dockerfile
    │       └── tmp/
    │           └── .keep
    ├── .dockerignore
    └── docker-compose.development.yml

```
#### Como funciona?

- `bin/setup_app.sh`: Arquivo de script para inicialização da aplicação. Responsável pela exclusão de arquivos temporários (pid), criação do banco de dados caso não o possua; execução de migrations e criação de arquivos de log temporários que assinalam criação do banco e execução do seeds.

- `docker/bash_aliases`: Arquivo de script com aliases para comandos recorrentes no ambiente docker.

- `docker/development/Dockerfile`: Imagem Docker para ambiente de desenvolvimento.

- `.dockerignore`: Arquivo ignore para a construção da imagem.

- `docker-compose.development`: Arquivo compose para desenvolvimento.

### 🐳 Docker Aliases para Desenvolvimento  

Este projeto utiliza Docker para facilitar o ambiente de desenvolvimento. **Além** de seu uso padrão, abaixo estão alguns atalhos definidos para agilizar comandos recorrentes.  

### 📌 Configuração Global

ℹ️  Utilizaremos `$` para representar seu terminal.

Para habilitar os atalhos execute:
```sh
$ source docker/bash_aliases.sh
```
Isso irá habilitar na sessão atual de seu terminal os seguintes comandos:

#### `BASE`  
Define um alias global para o comando base do Docker Compose:

```sh
alias -g BASE='docker compose -f "docker-compose.development.yml"'
```

```
$ echo BASE
> docker compose -f docker-compose.development.yml
```

Exemplo de uso:

```sh
$ BASE build # Comando de build
$ BASE up -d # Comando de up para nosso container
$ BASE run -it web bash # Executa o bash do container
```

#### `docker-clean`

Função que remove todos os containers e imagens Docker, além de limpar arquivos temporários do banco de dados:

```sh
docker-clean(){
  docker stop $(docker ps -aq)
  docker rmi -f $(docker images -aq)
  rm ./docker/development/tmp/.db-created
  rm ./docker/development/tmp/.db-seeded
}
```

#### O que faz?

- Para todos os containers em execução.
- Remove todas as imagens Docker.
- Exclui arquivos temporários de banco de dados gerados na inicialização do container.


### 🚀 Comandos de Desenvolvimento

`docker-build`
```sh
alias docker-build='BASE build'
```
Compila a imagem Docker do projeto.

`docker-up`
```sh
alias docker-up='BASE up'
Inicia os containers do projeto.
```

`docker-up-d`
```sh
alias docker-up-d='BASE up -d'
```
Inicia os containers em modo desacoplado (background).

`docker-down`
```sh
alias docker-down='BASE down'
```
Para e remove os containers em execução.


`docker-stop`
```sh
alias docker-stop='docker stop $(docker ps -aq)'
```
Para todos os containers ativos.

`docker-rmi`
```sh
alias docker-rmi='docker rmi -f $(docker images -aq)'
```
Remove todas as imagens Docker.

### 🎯 Comandos Rails

⚠️ Os comandos a seguir necessitam que o container esteja em funcionamento.

`docker-rails`
```sh
alias docker-rails='BASE exec web bundle exec rails'
```
Executa comandos do Rails dentro do container.
Exemplo:

```sh
docker-rails db:migrate
```
`docker-bundle`
```sh
alias docker-bundle='BASE exec web bundle'
```
Executa comandos do Bundler dentro do container.
Exemplo:

```sh
docker-bundle install
```
`docker-rake`
```sh
alias docker-rake='BASE exec web bundle exec rake'
```
Executa Rake tasks no container.
Exemplo:

```sh
docker-rake db:seed
```
`docker-console`
```sh
alias docker-console='BASE exec web rails console'
```
Abre o Rails console dentro do container.

`docker-rubocop`
```sh
alias docker-rubocop='BASE exec web bundle exec rubocop'
```
Executa o Rubocop para verificar padrões de código.

`docker-rspec`
```sh
alias docker-rspec='BASE exec web bundle exec rspec'
```
Executa os testes RSpec do projeto.

