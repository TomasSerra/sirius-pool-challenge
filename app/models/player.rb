class Player < ApplicationRecord
  has_many :matches_as_player1, class_name: "Match", foreign_key: "player1_id"
  has_many :matches_as_player2, class_name: "Match", foreign_key: "player2_id"
  has_many :won_matches, class_name: "Match", foreign_key: "winner_id"

  validates :name, presence: true
  validates :profile_picture_url, presence: true
  validates :ranking, numericality: { only_integer: true }, allow_nil: true

  before_create :calculate_ranking
  after_update :recalculate_rankings_if_active_changed

  default_scope { where(active: true) }
  scope :by_name, ->(name) { where("name LIKE ?", "%#{name}%") if name.present? }
  scope :order_by, ->(order_type) {
    if order_type.present?
      direction = order_type.start_with?("-") ? :desc : :asc
      field = order_type.delete_prefix("-")
      order(field => direction)
    end
  }

  private

  def recalculate_rankings_if_active_changed
    if saved_change_to_attribute?(:active)
      UpdatePlayerRankingsJob.perform_later
    end
  end

  def recalculate_rankings
    UpdatePlayerRankingsJob.perform_later
  end

  def calculate_ranking
    if wins > 0
      self.ranking = nil
      recalculate_rankings
    else
      highest_ranking = Player.maximum(:ranking)
      self.ranking = highest_ranking ? highest_ranking + 1 : 1
    end
  end
end
