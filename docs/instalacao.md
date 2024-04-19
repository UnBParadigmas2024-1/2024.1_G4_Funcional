## Instalação 
**Linguagens**: Haskell<br>
**Tecnologias**: Cabal<br>
Docker

## Instalando o Cabal
Para a instalação do cabal serão necessárias alguns pacotes como: curl e wget

#### 1- Atualize o cache do pacote
```sudo apt update```

#### 2- Instale o curl e o wget
```sudo apt install curl wget```

Esses comandos instalam o Curl e o Wget, que são ferramentas para transferência de dados via URLs.

#### 3- Instale o compilador C++
```sudo apt instal g++```

#### 4- Instale a ferramenta make
```sudo apt instal make```

Este comando instala a ferramenta make, que é um utilitário para automatizar o processo de compilação de programas.

#### 5- Instale o GHC e o Cabal usando ghcup
```curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh```

Este comando baixa e executa o script de instalação do ghcup, uma ferramenta para instalar e gerenciar o GHC (Glasgow Haskell Compiler) e o Cabal.

Após seguir esses passos, o Cabal deve estar instalado e pronto para uso em seu sistema. Você pode verificar a instalação do Cabal executando o comando:

```cabal --version```

### instalando o docker

[Windows](https://docs.docker.com/desktop/install/windows-install/) <br>
[Ubuntu](https://docs.docker.com/engine/install/ubuntu/)<br>
[Manjaro linux](https://manjariando.com.br/docker/)<br>

obs: verifique sua distro linux pois pode haver a necessidade de alguns passos extras ou permissões de administrador


## Uso 
Para rodar o código é necessária a instalação do docker.

### Vá para a pasta do game
    cd src
### Faça o build do projeto
    make build
### Rode o game
    make up
