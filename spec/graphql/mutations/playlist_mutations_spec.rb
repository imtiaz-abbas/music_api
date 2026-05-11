require 'rails_helper'

RSpec.describe "Playlist mutations" do
  let(:result) { MusicApiSchema.execute(query, variables: { input: input }, context: {}) }

  describe "createPlaylist" do
    let(:query) do
      <<~GQL
        mutation($input: CreatePlaylistInput!) {
          createPlaylist(input: $input) { playlist { id name } errors }
        }
      GQL
    end

    context "with valid input" do
      let(:input) { { name: "Chill Mix" } }

      it "creates the playlist" do
        expect { result }.to change(Playlist, :count).by(1)
        expect(result.dig("data", "createPlaylist", "playlist", "name")).to eq("Chill Mix")
        expect(result.dig("data", "createPlaylist", "errors")).to be_empty
      end
    end

    context "with blank name" do
      let(:input) { { name: "" } }

      it "returns errors without creating" do
        expect { result }.not_to change(Playlist, :count)
        expect(result.dig("data", "createPlaylist", "errors")).not_to be_empty
      end
    end
  end

  describe "updatePlaylist" do
    let(:query) do
      <<~GQL
        mutation($input: UpdatePlaylistInput!) {
          updatePlaylist(input: $input) { playlist { name } errors }
        }
      GQL
    end

    context "when found" do
      let(:playlist) { create(:playlist, name: "Old Name") }
      let(:input) { { id: playlist.id, name: "New Name" } }

      it "updates the playlist" do
        expect(result.dig("data", "updatePlaylist", "playlist", "name")).to eq("New Name")
        expect(result.dig("data", "updatePlaylist", "errors")).to be_empty
      end
    end

    context "when not found" do
      let(:input) { { id: 0 } }

      it "returns an error" do
        expect(result.dig("data", "updatePlaylist", "errors")).to include(match(/not found/))
      end
    end
  end

  describe "deletePlaylist" do
    let(:query) do
      <<~GQL
        mutation($input: DeletePlaylistInput!) {
          deletePlaylist(input: $input) { success errors }
        }
      GQL
    end

    context "when found" do
      let!(:playlist) { create(:playlist) }
      let(:input) { { id: playlist.id } }

      it "deletes the playlist" do
        expect { result }.to change(Playlist, :count).by(-1)
        expect(result.dig("data", "deletePlaylist", "success")).to be true
      end
    end

    context "when not found" do
      let(:input) { { id: 0 } }

      it "returns success false with an error" do
        expect(result.dig("data", "deletePlaylist", "success")).to be false
        expect(result.dig("data", "deletePlaylist", "errors")).to include(match(/not found/))
      end
    end
  end

  describe "addSongToPlaylist" do
    let(:query) do
      <<~GQL
        mutation($input: AddSongToPlaylistInput!) {
          addSongToPlaylist(input: $input) { playlist { name songs { title } } errors }
        }
      GQL
    end

    context "with valid ids" do
      let(:playlist) { create(:playlist) }
      let(:song) { create(:song) }
      let(:input) { { playlistId: playlist.id, songId: song.id } }

      it "adds the song to the playlist" do
        expect { result }.to change(PlaylistSong, :count).by(1)
        expect(result.dig("data", "addSongToPlaylist", "playlist", "songs", 0, "title")).to eq(song.title)
        expect(result.dig("data", "addSongToPlaylist", "errors")).to be_empty
      end
    end

    context "with invalid playlist id" do
      let(:song) { create(:song) }
      let(:input) { { playlistId: 0, songId: song.id } }

      it "returns an error" do
        expect(result.dig("data", "addSongToPlaylist", "errors")).to include(match(/not found/))
      end
    end

    context "with invalid song id" do
      let(:playlist) { create(:playlist) }
      let(:input) { { playlistId: playlist.id, songId: 0 } }

      it "returns an error" do
        expect(result.dig("data", "addSongToPlaylist", "errors")).to include(match(/not found/))
      end
    end
  end
end
