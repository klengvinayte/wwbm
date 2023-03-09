class Question < ApplicationRecord

  QUESTION_LEVELS = (0..14).freeze

  # the question should have a level of difficulty
  validates :level, presence: true, inclusion: { in: QUESTION_LEVELS }

  # The text of the question (cannot be empty and should not be repeated)
  validates :text, presence: true, uniqueness: true, allow_blank: false

  # Answer options (we always store the correct one in the first one)
  validates :answer1, :answer2, :answer3, :answer4, presence: true
end
