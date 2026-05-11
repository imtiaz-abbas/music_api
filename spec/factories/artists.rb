FactoryBot.define do
  factory :artist do
    sequence(:name) { |n| "Artist #{n}" }
    genre { "Rock" }
  end
end
