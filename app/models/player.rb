class Player < ApplicationRecord
  has_many :matches_as_player1, class_name: "Match", foreign_key: "player1_id"
  has_many :matches_as_player2, class_name: "Match", foreign_key: "player2_id"
  has_many :won_matches, class_name: "Match", foreign_key: "winner_id"

  validates :name, presence: true
  validates :profile_picture_url, presence: true
  validates :ranking, numericality: { only_integer: true }
end
