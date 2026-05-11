require 'rails_helper'

RSpec.describe "GraphQL artists queries" do
  let(:result) { MusicApiSchema.execute(query, variables: variables, context: {}) }

  describe "artists" do
    let(:query) { "{ artists { id name genre } }" }
    let(:variables) { {} }

    it "returns all artists" do
      create_list(:artist, 3)
      expect(result["errors"]).to be_nil
      expect(result.dig("data", "artists").length).to eq(3)
    end
  end

  describe "artist(id:)" do
    let(:query) { "query($id: ID!) { artist(id: $id) { id name genre } }" }

    context "when found" do
      let(:artist) { create(:artist, name: "Radiohead", genre: "Alternative") }
      let(:variables) { { id: artist.id } }

      it "returns the artist" do
        expect(result["errors"]).to be_nil
        expect(result.dig("data", "artist", "name")).to eq("Radiohead")
        expect(result.dig("data", "artist", "genre")).to eq("Alternative")
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
