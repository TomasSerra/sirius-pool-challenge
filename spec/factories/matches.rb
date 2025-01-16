FactoryBot.define do
  factory :match do
    id { Faker::Number.unique.within(range: 1..9_223_372_036_854_775_807) }
    player1_id { Faker::Number.unique.within(range: 1..9_223_372_036_854_775_807) }
    player2_id { Faker::Number.unique.within(range: 1..9_223_372_036_854_775_807) }
    start_time { Faker::Time.between(from: DateTime.now - 1, to: DateTime.now) }
    end_time { Faker::Time.between(from: DateTime.now, to: DateTime.now + 1) }
    winner_id { Faker::Number.unique.within(range: 1..9_223_372_036_854_775_807) }
    table_number { Faker::Number.between(from: 1, to: 100) }
  end
end
