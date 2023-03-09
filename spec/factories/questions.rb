FactoryBot.define do
  # Factory name (question)
  factory :question do
    # Generating a sequence of unique question texts
    # Parameter n guarantees the uniqueness of the question
    sequence(:text) { |n| "What year was the space odyssey #{n}?" }

    # We generate levels from 0 to 14
    sequence(:level) { |n| n % 15 }

    # Values of response fields
    # We will make the answers random for beauty
    answer1 { "#{rand(2001)}" }
    answer2 { "#{rand(2001)}" }
    answer3 { "#{rand(2001)}" }
    answer4 { "#{rand(2001)}" }
  end
end