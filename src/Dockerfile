
FROM haskell:8

WORKDIR /usr/src/app


COPY ./G4FuncionalTermo.cabal /usr/src/app/G4FuncionalTermo.cabal
COPY ./app/ .
COPY ./app/ ./app
COPY . .

RUN cabal update
RUN cabal build --only-dependencies -j4

CMD ["cabal", "run"]
