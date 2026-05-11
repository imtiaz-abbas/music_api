# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    # --- Artists ---
    field :artists, [Types::ArtistType], null: false,
      description: "Returns all artists"
    def artists
      Artist.all
    end

    field :artist, Types::ArtistType, null: true,
      description: "Find a single artist by ID. Raises an error if not found." do
      argument :id, ID, required: true, description: "Artist ID"
    end
    def artist(id:)
      Artist.find(id)
    rescue ActiveRecord::RecordNotFound
      raise GraphQL::ExecutionError, "Artist with id #{id} not found"
    end

    # --- Songs ---
    field :songs, [Types::SongType], null: false,
      description: "Returns all songs"
    def songs
      Song.all
    end

    field :song, Types::SongType, null: true,
      description: "Find a single song by ID. Raises an error if not found." do
      argument :id, ID, required: true, description: "Song ID"
    end
    def song(id:)
      Song.find(id)
    rescue ActiveRecord::RecordNotFound
      raise GraphQL::ExecutionError, "Song with id #{id} not found"
    end

    # --- Playlists ---
    field :playlists, [Types::PlaylistType], null: false,
      description: "Returns all playlists"
    def playlists
      Playlist.all
    end

    field :playlist, Types::PlaylistType, null: true,
      description: "Find a single playlist by ID. Raises an error if not found." do
      argument :id, ID, required: true, description: "Playlist ID"
    end
    def playlist(id:)
      Playlist.find(id)
    rescue ActiveRecord::RecordNotFound
      raise GraphQL::ExecutionError, "Playlist with id #{id} not found"
    end
  end
end
