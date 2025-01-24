FactoryBot.define do
  factory :player do
    id { Faker::Number.unique.number }
    name { Faker::Name.name }
    ranking { 0 }
    profile_picture_url { "https://cloudchallengesirius.blob.core.windows.net/files/profile_pictures/3124n23n42n4u-crefv24" }
    preferred_cue { Faker::Lorem.word }

    trait :with_name_and_preferred_cue do
      name { Faker::Name.name }
      preferred_cue { Faker::Lorem.word }
    end
  end
end
