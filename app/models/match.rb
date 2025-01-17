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
  validate :table_must_be_available
  validate :players_must_be_available

  scope :by_date, ->(date_string) {
    if date_string.present?
      date = Date.parse(date_string) rescue nil
      if date
        start_of_day = Time.zone.local(date.year, date.month, date.day).beginning_of_day
        end_of_day = start_of_day.end_of_day
        where(start_time: start_of_day..end_of_day)
      end
    end
  }
  scope :upcoming, -> { where("start_time > ?", Time.current) }
  scope :ongoing, -> { where("start_time <= ? AND end_time >= ?", Time.current, Time.current) }
  scope :completed, -> { where("end_time < ?", Time.current) }

  private

  def start_time_should_be_before_end_time
    if start_time >= end_time
      errors.add(:start_time, "must be earlier than end time")
    end
  end

  def table_must_be_available
    unless table_available?(table_number, start_time, end_time)
      errors.add(:table_number, "is already occupied during this time")
    end
  end

  def table_available?(table_number, start_time, end_time)
    Match.where(table_number: table_number)
         .where('start_time < ? AND end_time > ?', end_time, start_time)
         .none?
  end

  def players_must_be_available
    unless player_available?(player1_id, start_time, end_time)
      errors.add(:player1, "is not available at the given time")
    end

    unless player_available?(player2_id, start_time, end_time)
      errors.add(:player2, "is not available at the given time")
    end
  end

  def player_available?(player_id, start_time, end_time)
    Match.where("player1_id = ? OR player2_id = ?", player_id, player_id)
         .where('start_time < ? AND end_time > ?', end_time, start_time)
         .none?
  end
end
