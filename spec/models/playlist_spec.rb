require 'rails_helper'

RSpec.describe Playlist, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:playlist_songs) }
    it { is_expected.to have_many(:songs).through(:playlist_songs) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
  end
end
