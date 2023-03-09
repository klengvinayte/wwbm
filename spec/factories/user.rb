FactoryBot.define do
  # # Factory name (user)
  factory :user do
    name { "Player#{rand(999)}" }
    sequence(:email) { |n| "someguy_#{n}@example.com" }

    is_admin { false }

    balance { 0 }

    after(:build) { |u| u.password_confirmation = u.password = "123456" }
  end
end