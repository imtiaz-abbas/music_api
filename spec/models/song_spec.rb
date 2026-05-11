require 'rails_helper'

RSpec.describe Song, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:artist) }
    it { is_expected.to have_many(:playlist_songs) }
    it { is_expected.to have_many(:playlists).through(:playlist_songs) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:duration) }
  end
end
