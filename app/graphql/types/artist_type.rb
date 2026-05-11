# frozen_string_literal: true

module Types
  class ArtistType < Types::BaseObject
    description "A musical artist or band"

    field :id,    ID,     null: false, description: "Unique identifier"
    field :name,  String, null: false, description: "Stage name or band name"
    field :genre, String, null: false, description: "Primary music genre"
    field :songs, [Types::SongType], null: false, description: "All songs by this artist"
  end
end
