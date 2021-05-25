FROM golang:alpine AS builder

# Set necessary environmet variables needed for our image
ENV GO111MODULE=on
ENV CGO_ENABLED=0
ENV GOOS=linux
ENV GOARCH=amd64

# Move to working directory /goviolin
WORKDIR /goviolin

# Copy and download dependency using go mod
COPY . .

RUN go mod download
RUN go mod verify

# Copy the code into the container
COPY . .

# Build the application
RUN go build -o goviolin .

# Move to /dist directory as the place for resulting binary folder
WORKDIR /dist

RUN ls
# Copy binary from build to main folder
RUN cp /goviolin/goviolin .

# Build a small image
FROM scratch

COPY --from=builder /dist/goviolin /
COPY ./ /

EXPOSE 8080
# Command to run
ENTRYPOINT ["./goviolin"]