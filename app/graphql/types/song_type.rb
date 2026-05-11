# frozen_string_literal: true

module Types
  class SongType < Types::BaseObject
    description "A single track belonging to an artist"

    field :id,               ID,      null: false, description: "Unique identifier"
    field :title,            String,  null: false, description: "Song title"
    field :duration,         Integer, null: false, description: "Duration in seconds"
    field :artist_id,        ID,      null: false, description: "Foreign key of the owning artist"
    field :duration_in_mins, String,  null: false, description: "Duration formatted as M:SS (e.g. 3:05)"
    field :artist,           Types::ArtistType, null: false, description: "The artist who recorded this song"

    def duration_in_mins
      total = object.duration
      "#{total / 60}:#{total % 60 < 10 ? "0#{total % 60}" : total % 60}"
    end

    def artist
      dataloader.with(Sources::RecordById, Artist).load(object.artist_id)
    end
  end
end
