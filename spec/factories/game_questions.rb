FactoryBot.define do
  factory :game_question do
    # Always the same distribution of answers, it is more convenient in tests
    # In d always true
    a { 4 }
    b { 3 }
    c { 2 }
    d { 1 }

    association :question
    association :game
  end
end