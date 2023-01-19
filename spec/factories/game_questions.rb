FactoryBot.define do
  factory :game_question do
    # Всегда одинаковое распределение ответов, в тестах это удобнее
    # В d всегда верный
    a { 4 }
    b { 3 }
    c { 2 }
    d { 1 }

    association :user
    association :game
  end
end