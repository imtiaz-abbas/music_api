# frozen_string_literal: true

module Types
  class PlaylistType < Types::BaseObject
    description "A named collection of songs"

    field :id,    ID,     null: false, description: "Unique identifier"
    field :name,  String, null: false, description: "Playlist name"
    field :songs, [Types::SongType], null: false, description: "Ordered list of songs in this playlist"
  end
end
