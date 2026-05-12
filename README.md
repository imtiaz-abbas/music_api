# music_api

A Rails API-only app exposing a GraphQL endpoint for a music collection domain — Artists, Songs, and Playlists.

## Stack

- Ruby on Rails 8 (API mode)
- PostgreSQL
- [graphql-ruby](https://graphql-ruby.org/)
- GraphiQL (in-browser IDE, development only)

## Setup

```bash
bundle install
rails db:create db:migrate db:seed
```

## Running the server

```bash
rails server
```

- GraphQL endpoint: `http://localhost:3000/graphql`
- GraphiQL IDE: `http://localhost:3000/graphiql`

## Running the test suite

```bash
bundle exec rspec
```

Run with documentation format to see each example:

```bash
bundle exec rspec --format documentation
```

Run a specific file:

```bash
bundle exec rspec spec/graphql/mutations/artist_mutations_spec.rb
```

## GraphQL operations

### Queries

```graphql
{ artists { id name genre } }
{ artist(id: "1") { name songs { title durationInMins } } }
{ songs { id title durationInMins artist { name } } }
{ playlists { id name songs { title } } }
```

### Mutations

```graphql
mutation {
  createArtist(input: { name: "Radiohead", genre: "Alternative" }) {
    artist { id name }
    errors
  }
}
```


DEMO

https://github.com/user-attachments/assets/83ed0c61-8f56-48de-a227-369699446ffb
