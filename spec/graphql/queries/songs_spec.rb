require 'rails_helper'

RSpec.describe "GraphQL songs queries" do
  let(:result) { MusicApiSchema.execute(query, variables: variables, context: {}) }

  describe "songs" do
    let(:query) { "{ songs { id title duration durationInMins } }" }
    let(:variables) { {} }

    it "returns all songs" do
      create_list(:song, 2)
      expect(result["errors"]).to be_nil
      expect(result.dig("data", "songs").length).to eq(2)
    end

    it "formats durationInMins correctly" do
      create(:song, duration: 193)
      mins = result.dig("data", "songs", 0, "durationInMins")
      expect(mins).to eq("3:13")
    end
  end

  describe "song(id:)" do
    let(:query) { "query($id: ID!) { song(id: $id) { id title artist { name } } }" }

    context "when found" do
      let(:song) { create(:song, title: "Creep") }
      let(:variables) { { id: song.id } }

      it "returns the song with its artist" do
        expect(result["errors"]).to be_nil
        expect(result.dig("data", "song", "title")).to eq("Creep")
        expect(result.dig("data", "song", "artist", "name")).to be_present
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
