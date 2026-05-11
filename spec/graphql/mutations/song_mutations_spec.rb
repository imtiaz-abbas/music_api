require 'rails_helper'

RSpec.describe "Song mutations" do
  let(:result) { MusicApiSchema.execute(query, variables: { input: input }, context: {}) }

  describe "createSong" do
    let(:query) do
      <<~GQL
        mutation($input: CreateSongInput!) {
          createSong(input: $input) { song { id title duration } errors }
        }
      GQL
    end

    context "with valid input" do
      let(:artist) { create(:artist) }
      let(:input) { { title: "Creep", duration: 238, artistId: artist.id } }

      it "creates the song" do
        expect { result }.to change(Song, :count).by(1)
        expect(result.dig("data", "createSong", "song", "title")).to eq("Creep")
        expect(result.dig("data", "createSong", "errors")).to be_empty
      end
    end

    context "with invalid artist_id" do
      let(:input) { { title: "Creep", duration: 238, artistId: 0 } }

      it "returns errors without creating" do
        expect { result }.not_to change(Song, :count)
        expect(result.dig("data", "createSong", "errors")).not_to be_empty
      end
    end
  end

  describe "updateSong" do
    let(:query) do
      <<~GQL
        mutation($input: UpdateSongInput!) {
          updateSong(input: $input) { song { title duration } errors }
        }
      GQL
    end

    context "when found" do
      let(:song) { create(:song, title: "Old Title") }
      let(:input) { { id: song.id, title: "New Title" } }

      it "updates the song" do
        expect(result.dig("data", "updateSong", "song", "title")).to eq("New Title")
        expect(result.dig("data", "updateSong", "errors")).to be_empty
      end
    end

    context "when not found" do
      let(:input) { { id: 0 } }

      it "returns an error" do
        expect(result.dig("data", "updateSong", "errors")).to include(match(/not found/))
      end
    end
  end

  describe "deleteSong" do
    let(:query) do
      <<~GQL
        mutation($input: DeleteSongInput!) {
          deleteSong(input: $input) { success errors }
        }
      GQL
    end

    context "when found" do
      let!(:song) { create(:song) }
      let(:input) { { id: song.id } }

      it "deletes the song" do
        expect { result }.to change(Song, :count).by(-1)
        expect(result.dig("data", "deleteSong", "success")).to be true
      end
    end

    context "when not found" do
      let(:input) { { id: 0 } }

      it "returns success false with an error" do
        expect(result.dig("data", "deleteSong", "success")).to be false
        expect(result.dig("data", "deleteSong", "errors")).to include(match(/not found/))
      end
    end
  end
end
