# Artists
arctic = Artist.create!(name: "Arctic Monkeys", genre: "Rock")
daft   = Artist.create!(name: "Daft Punk",      genre: "Electronic")
kendrick = Artist.create!(name: "Kendrick Lamar", genre: "Hip-Hop")

# Songs
s1 = Song.create!(title: "Do I Wanna Know?",  duration: 272, artist: arctic)
s2 = Song.create!(title: "R U Mine?",          duration: 202, artist: arctic)
s3 = Song.create!(title: "Get Lucky",          duration: 248, artist: daft)
s4 = Song.create!(title: "Harder Better Faster", duration: 224, artist: daft)
s5 = Song.create!(title: "HUMBLE.",            duration: 177, artist: kendrick)
s6 = Song.create!(title: "DNA.",               duration: 185, artist: kendrick)

# Playlists
p1 = Playlist.create!(name: "Morning Mix")
p2 = Playlist.create!(name: "Late Night")

# PlaylistSongs
PlaylistSong.create!(playlist: p1, song: s1)
PlaylistSong.create!(playlist: p1, song: s3)
PlaylistSong.create!(playlist: p1, song: s5)
PlaylistSong.create!(playlist: p2, song: s2)
PlaylistSong.create!(playlist: p2, song: s4)
PlaylistSong.create!(playlist: p2, song: s6)

puts "Seeded: #{Artist.count} artists, #{Song.count} songs, #{Playlist.count} playlists"