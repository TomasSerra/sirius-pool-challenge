class Match < ApplicationRecord
  belongs_to :player1, class_name: "Player", foreign_key: "player1_id"
  belongs_to :player2, class_name: "Player", foreign_key: "player2_id"
  belongs_to :winner, class_name: "Player", foreign_key: "winner_id", optional: true

  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :table_number, presence: true
  validates :player1, presence: true
  validates :player2, presence: true
  validate :start_time_should_be_before_end_time

  private

  def start_time_should_be_before_end_time
    if start_time >= end_time
      errors.add(:start_time, "must be earlier than end time")
    end
  end
end
