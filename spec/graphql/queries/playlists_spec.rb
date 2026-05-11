require 'rails_helper'

RSpec.describe "GraphQL playlists queries" do
  let(:result) { MusicApiSchema.execute(query, variables: variables, context: {}) }

  describe "playlists" do
    let(:query) { "{ playlists { id name } }" }
    let(:variables) { {} }

    it "returns all playlists" do
      create_list(:playlist, 2)
      expect(result["errors"]).to be_nil
      expect(result.dig("data", "playlists").length).to eq(2)
    end
  end

  describe "playlist(id:)" do
    let(:query) { "query($id: ID!) { playlist(id: $id) { id name songs { title } } }" }

    context "when found" do
      let(:playlist) { create(:playlist, name: "Chill Mix") }
      let(:song) { create(:song) }
      let(:variables) { { id: playlist.id } }

      before { playlist.songs << song }

      it "returns the playlist with its songs" do
        expect(result["errors"]).to be_nil
        expect(result.dig("data", "playlist", "name")).to eq("Chill Mix")
        expect(result.dig("data", "playlist", "songs").length).to eq(1)
      end
    end

    context "when not found" do
      let(:variables) { { id: 0 } }

      it "returns an execution error" do
        expect(result["errors"].first["message"]).to match(/not found/)
      end
    end
  end
end
