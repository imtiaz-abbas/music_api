require 'rails_helper'

RSpec.describe "Artist mutations" do
  let(:result) { MusicApiSchema.execute(query, variables: { input: input }, context: {}) }

  describe "createArtist" do
    let(:query) do
      <<~GQL
        mutation($input: CreateArtistInput!) {
          createArtist(input: $input) { artist { id name genre } errors }
        }
      GQL
    end

    context "with valid input" do
      let(:input) { { name: "Radiohead", genre: "Alternative" } }

      it "creates the artist" do
        expect { result }.to change(Artist, :count).by(1)
        expect(result.dig("data", "createArtist", "artist", "name")).to eq("Radiohead")
        expect(result.dig("data", "createArtist", "errors")).to be_empty
      end
    end

    context "with missing name" do
      let(:input) { { name: "", genre: "Rock" } }

      it "returns errors without creating" do
        expect { result }.not_to change(Artist, :count)
        expect(result.dig("data", "createArtist", "errors")).not_to be_empty
      end
    end
  end

  describe "updateArtist" do
    let(:query) do
      <<~GQL
        mutation($input: UpdateArtistInput!) {
          updateArtist(input: $input) { artist { name genre } errors }
        }
      GQL
    end

    context "when found" do
      let(:artist) { create(:artist, name: "Old Name") }
      let(:input) { { id: artist.id, name: "New Name" } }

      it "updates the artist" do
        expect(result.dig("data", "updateArtist", "artist", "name")).to eq("New Name")
        expect(result.dig("data", "updateArtist", "errors")).to be_empty
      end
    end

    context "when not found" do
      let(:input) { { id: 0 } }

      it "returns an error" do
        expect(result.dig("data", "updateArtist", "errors")).to include(match(/not found/))
      end
    end
  end

  describe "deleteArtist" do
    let(:query) do
      <<~GQL
        mutation($input: DeleteArtistInput!) {
          deleteArtist(input: $input) { success errors }
        }
      GQL
    end

    context "when found" do
      let!(:artist) { create(:artist) }
      let(:input) { { id: artist.id } }

      it "deletes the artist" do
        expect { result }.to change(Artist, :count).by(-1)
        expect(result.dig("data", "deleteArtist", "success")).to be true
      end
    end

    context "when not found" do
      let(:input) { { id: 0 } }

      it "returns success false with an error" do
        expect(result.dig("data", "deleteArtist", "success")).to be false
        expect(result.dig("data", "deleteArtist", "errors")).to include(match(/not found/))
      end
    end
  end
end
