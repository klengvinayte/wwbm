class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  before_validation :set_name, on: :create

  # the name is not empty, the email validates the Device
  validates :name, presence: true

  # the field is Boolean only (false/true)
  validates :is_admin, inclusion: { in: [true, false] }, allow_nil: false

  # this field should only be an integer
  validates :balance, numericality: { only_integer: true }, allow_nil: false

  has_many :games, dependent: :destroy

  # calculation of average winnings for all user games
  def average_prize
    (balance.to_f / games.count).round unless games.count.zero?
  end

  def set_name
    self.name = "Player №#{rand(777)}" if self.name.blank?
  end
end
