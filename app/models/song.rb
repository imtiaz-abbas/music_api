class Song < ApplicationRecord
  belongs_to :artist
  has_many :playlist_songs, dependent: :destroy
  has_many :playlists, through: :playlist_songs

  validates :title,    presence: true
  validates :duration, presence: true, numericality: { greater_than: 0 }
end