# Multi-stage build producing a tiny, non-root, distroless image.
FROM golang:1.22 AS build
WORKDIR /src
COPY go.mod ./
COPY main.go ./
RUN CGO_ENABLED=0 GOOS=linux go build -o /orders-api .

FROM gcr.io/distroless/static:nonroot
COPY --from=build /orders-api /orders-api
USER nonroot:nonroot
EXPOSE 8080
ENTRYPOINT ["/orders-api"]
