# --- Estágio 1: Compilação ---
    FROM golang:1.21-alpine AS builder

    # Define o diretório de trabalho
    WORKDIR /app
    
    # Copia os arquivos de dependência (se houver go.mod)
    # Caso não tenha iniciado um módulo, o comando abaixo falhará, 
    # então use 'go mod init echo-app' antes.
    COPY go.mod ./
    RUN go mod download
    
    # Copia o código fonte
    COPY main.go ./
    
    # Compila o binário estaticamente (importante para imagens leves)
    RUN CGO_ENABLED=0 GOOS=linux go build -o /go-echo-app main.go
    
    # --- Estágio 2: Execução ---
    FROM alpine:3.18
    
    # Adiciona um usuário não-root por segurança (boa prática no OpenShift)
    RUN adduser -D appuser
    USER appuser
    
    WORKDIR /
    
    # Copia apenas o binário do estágio anterior
    COPY --from=builder /go-echo-app /go-echo-app
    
    # Porta que o Go está ouvindo
    EXPOSE 8080
    
    # Comando para rodar a aplicação
    ENTRYPOINT ["/go-echo-app"]