class Player < ApplicationRecord
  has_many :matches_as_player1, class_name: "Match", foreign_key: "player1_id"
  has_many :matches_as_player2, class_name: "Match", foreign_key: "player2_id"
  has_many :won_matches, class_name: "Match", foreign_key: "winner_id"

  validates :name, presence: true
  validates :profile_picture_url, presence: true
  validates :ranking, numericality: { only_integer: true }

  after_create :recalculate_rankings
  after_update :recalculate_rankings_if_active_changed

  default_scope { where(active: true) }
  scope :by_name, ->(name) { where("name LIKE ?", "%#{name}%") if name.present? }

  private

  def recalculate_rankings_if_active_changed
    if saved_change_to_attribute?(:active)
      recalculate_rankings
    end
  end

  def recalculate_rankings
    UpdatePlayerRankingsJob.perform_later
  end
end
