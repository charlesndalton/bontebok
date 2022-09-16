FROM docker.io/clux/muslrust:1.59.0 as cargo-build

WORKDIR /tmp/bontebok-bot
COPY Cargo.toml /tmp/bontebok-bot
COPY Cargo.lock /tmp/bontebok-bot

# To cache dependencies, create a layer that compiles dependencies and some rust src that won't change, 
# and then another layer that compiles our source.
RUN echo 'fn main() {}' >> /tmp/bontebok-bot/dummy.rs

RUN sed -i 's|src/main.rs|dummy.rs|g' Cargo.toml
RUN env CARGO_PROFILE_RELEASE_DEBUG=1 cargo build --target x86_64-unknown-linux-musl --release

RUN sed -i 's|dummy.rs|src/main.rs|g' Cargo.toml
COPY . /tmp/bontebok-bot
RUN env CARGO_PROFILE_RELEASE_DEBUG=1 cargo build --target x86_64-unknown-linux-musl --release


FROM docker.io/alpine:latest

RUN apk add --no-cache tini

COPY --from=cargo-build /tmp/bontebok-bot/target/x86_64-unknown-linux-musl/release/bontebok-bot /
WORKDIR /

ENV RUST_LOG=INFO
CMD ["./bontebok-bot"]
