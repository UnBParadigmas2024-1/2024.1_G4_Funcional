# Use uma imagem base com suporte a Haskell (por exemplo, haskell:8)
FROM haskell:8

# Defina o diretório de trabalho dentro do contêiner
WORKDIR /usr/src/app

#RUN cabal update

# Copie o arquivo .cabal e o arquivo stack.yaml para o diretório de trabalho
COPY ./termo-hs.cabal /usr/src/app/termo-hs.cabal
# stack.yaml ./
COPY ./app/ .
COPY ./app/ ./app
COPY . .


# Instale as dependências
#RUN stack setup
#RUN stack build --only-dependencies
#RUN cabal install --dependencies-only --overwrite-policy=always
RUN cabal update
RUN cabal build --only-dependencies -j4
#RUN cabal build
#RUN cabal run
#RUN cabal install --dependencies-only --overwrite-policy=always
#RUN cabal install random






#RUN cabal run


# Comando para compilar e executar o aplicativo
CMD ["cabal", "run"]
