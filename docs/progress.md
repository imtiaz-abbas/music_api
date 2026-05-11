# Music API — Rails + GraphQL Handoff Doc
> Continue from Phase 5. Phases 1–4 are complete.

---

## Project Overview

**App name:** `music_api`  
**Stack:** Rails API-only + PostgreSQL + graphql-ruby gem  
**Domain:** Music collection — Artists, Songs, Playlists

---

## What's Already Done

### Phase 1 — Setup ✅
- Rails API-only app created: `rails new music_api --api --database=postgresql`
- Gems installed: `graphql`, `graphiql-rails`, `rack-cors`
- GraphQL scaffold generated: `rails generate graphql:install`
- GraphiQL mounted at `/graphiql` in `config/routes.rb`
- CORS configured in `config/initializers/cors.rb`

### Phase 2 — Models ✅

**Models and associations:**

```ruby
# Artist — has_many :songs
# Song    — belongs_to :artist, has_many :playlist_songs, has_many :playlists through: :playlist_songs
# Playlist — has_many :playlist_songs, has_many :songs through: :playlist_songs
# PlaylistSong — belongs_to :playlist, belongs_to :song
```

**Seed data:** 3 artists, 6 songs, 2 playlists, 6 playlist_songs already seeded.

### Phase 3 — GraphQL Types ✅

Files in `app/graphql/types/`:

```ruby
# artist_type.rb
field :id, :name, :genre
field :songs, [Types::SongType]

# song_type.rb
field :id, :title, :duration, :artist_id
field :duration_in_mins, String  # custom resolver: "3:13" format
field :artist, Types::ArtistType

# playlist_type.rb
field :id, :name
field :songs, [Types::SongType]
```

### Phase 4 — Queries & Resolvers ✅

`app/graphql/types/query_type.rb` has these working queries:

```graphql
artists                    # returns all artists
artist(id: ID!)            # returns single artist or null
songs                      # returns all songs
song(id: ID!)              # returns single song or null
playlists                  # returns all playlists
playlist(id: ID!)          # returns single playlist or null
```

Nested queries work — e.g. `playlist { songs { artist { name } } }` (3 levels deep).

---

## What Needs to Be Built

### Phase 5 — Mutations ⬅️ START HERE

Create these files in `app/graphql/mutations/`:

#### 1. `create_artist.rb`
Arguments: `name: String!, genre: String!`  
Returns: `artist: ArtistType, errors: [String!]!`

#### 2. `create_song.rb`
Arguments: `title: String!, duration: Int!, artist_id: ID!`  
Returns: `song: SongType, errors: [String!]!`

#### 3. `create_playlist.rb`
Arguments: `name: String!`  
Returns: `playlist: PlaylistType, errors: [String!]!`

#### 4. `add_song_to_playlist.rb`
Arguments: `playlist_id: ID!, song_id: ID!`  
Returns: `playlist: PlaylistType, errors: [String!]!`

**Pattern to follow for every mutation:**
```ruby
module Mutations
  class CreateArtist < BaseMutation
    argument :name,  String, required: true
    argument :genre, String, required: true

    field :artist, Types::ArtistType, null: true
    field :errors, [String], null: false

    def resolve(name:, genre:)
      artist = Artist.new(name: name, genre: genre)
      if artist.save
        { artist: artist, errors: [] }
      else
        { artist: nil, errors: artist.errors.full_messages }
      end
    end
  end
end
```

Then register all mutations in `app/graphql/types/mutation_type.rb`:
```ruby
field :create_artist,        mutation: Mutations::CreateArtist
field :create_song,          mutation: Mutations::CreateSong
field :create_playlist,      mutation: Mutations::CreatePlaylist
field :add_song_to_playlist, mutation: Mutations::AddSongToPlaylist
```

Note: all mutation arguments are wrapped in `input:` automatically by graphql-ruby.
Test with: `mutation { createArtist(input: { name: "...", genre: "..." }) { artist { id } errors } }`

---

### Phase 6 — Error Handling

Goals:
- Raise `GraphQL::ExecutionError` for not-found cases in queries
- Return validation errors via the `errors` field in mutations
- Handle `ActiveRecord::RecordNotFound` and `ActiveRecord::RecordInvalid` gracefully

Example — update `query_type.rb` single lookups:
```ruby
def artist(id:)
  Artist.find(id)
rescue ActiveRecord::RecordNotFound
  raise GraphQL::ExecutionError, "Artist with id #{id} not found"
end
```

---

### Phase 7 — N+1 Prevention

The classic N+1 to demonstrate:
```graphql
{
  playlists {
    songs {
      artist { name }   # fires 1 query per song to load artist
    }
  }
}
```

Fix using the `dataloader` gem (included with graphql-ruby):

In `song_type.rb`, replace the `artist` field resolver with a batched loader:
```ruby
def artist
  dataloader.with(Sources::RecordById, Artist).load(object.artist_id)
end
```

Create `app/graphql/sources/record_by_id.rb`:
```ruby
class Sources::RecordById < GraphQL::Dataloader::Source
  def initialize(model)
    @model = model
  end

  def fetch(ids)
    records = @model.where(id: ids).index_by(&:id)
    ids.map { |id| records[id] }
  end
end
```

Enable dataloader in `app/graphql/music_api_schema.rb`:
```ruby
use GraphQL::Dataloader
```

---

### Phase 8 — GraphiQL & Docs

- Add `description` to all types and fields
- Mount GraphiQL already done — test all queries and mutations end to end
- Run introspection: `{ __schema { types { name fields { name description } } } }`
- Record demo video showing: query → mutation → nested query → N+1 fix
- Push to GitHub with README

---

## Key Files Reference

```
app/
  graphql/
    music_api_schema.rb          # root schema
    types/
      query_type.rb              # all queries + resolvers
      mutation_type.rb           # registers all mutations
      artist_type.rb
      song_type.rb               # has custom duration_in_mins resolver
      playlist_type.rb
      base_object.rb
      base_mutation.rb
    mutations/                   # ← create these in Phase 5
      base_mutation.rb
      create_artist.rb
      create_song.rb
      create_playlist.rb
      add_song_to_playlist.rb
    sources/                     # ← create this in Phase 7
      record_by_id.rb
  models/
    artist.rb
    song.rb
    playlist.rb
    playlist_song.rb
config/
  routes.rb                      # /graphql + /graphiql mounted
  initializers/cors.rb           # CORS open for development
db/
  seeds.rb                       # 3 artists, 6 songs, 2 playlists seeded
```

---

## GraphQL Concepts Covered (reference)

| Concept | Where |
|---|---|
| Type definition | `artist_type.rb`, `song_type.rb`, `playlist_type.rb` |
| Field resolver | `def duration_in_mins` in `song_type.rb` |
| Query + argument | `artist(id: ID!)` in `query_type.rb` |
| Nested query | `playlist → songs → artist` — 3 levels |
| Mutation + input | `create_artist(input: {...})` |
| Errors field pattern | `{ artist: nil, errors: [...] }` |
| ExecutionError | raised in query resolvers for not found |
| N+1 fix | `GraphQL::Dataloader` + `Sources::RecordById` |
| Introspection | `__schema`, `__type` queries in GraphiQL |
| camelCase auto-convert | `artist_id` → `artistId`, `duration_in_mins` → `durationInMins` |
