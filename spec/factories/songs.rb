FactoryBot.define do
  factory :song do
    sequence(:title) { |n| "Song #{n}" }
    duration { 200 }
    association :artist
  end
end
