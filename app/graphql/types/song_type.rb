# frozen_string_literal: true

module Types
  class SongType < Types::BaseObject
    field :id,               ID,      null: false
    field :title,            String,  null: false
    field :duration,         Integer, null: false
    field :artist_id,        ID,      null: false
    field :duration_in_mins, String,  null: false
    field :artist,           Types::ArtistType, null: false

    def duration_in_mins
      total = object.duration
      "#{total / 60}:#{total % 60 < 10 ? "0#{total % 60}" : total % 60}"
    end

    def artist
      dataloader.with(Sources::RecordById, Artist).load(object.artist_id)
    end
  end
end
