class Match < ApplicationRecord
  belongs_to :player1, class_name: "Player", foreign_key: "player1_id"
  belongs_to :player2, class_name: "Player", foreign_key: "player2_id"
  belongs_to :winner, class_name: "Player", foreign_key: "winner_id", optional: true

  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :table_number, presence: true
  validates :player1, presence: true
  validates :player2, presence: true

  validate :players_are_different
  validate :winner_is_valid
  validate :start_time_should_be_before_end_time
  validate :table_must_be_available
  validate :players_must_be_available

  before_save :adjust_wins
  before_destroy :match_should_not_be_started

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

  scope :order_by, ->(order_type) {
    if order_type.present?
      direction = order_type.start_with?("-") ? :desc : :asc
      field = order_type.delete_prefix("-")
      order(field => direction)
    end
  }

  scope :upcoming, ->() {
    where("start_time > ?", Time.zone.now)
  }
  scope :ongoing, ->() {
    where("start_time <= ? AND end_time >= ?", Time.zone.now, Time.zone.now)
  }
  scope :completed, ->() {
    where("end_time < ?", Time.zone.now)
  }

  scope :with_status, ->(status) {
    status_mapping = {
      "upcoming" => :upcoming,
      "ongoing" => :ongoing,
      "completed" => :completed
    }
    if status_mapping[status]
      public_send(status_mapping[status])
    end
  }

  private

  def start_time_should_be_before_end_time
    if start_time >= end_time
      errors.add(:start_time, "must be earlier than end time")
    end
  end

  def table_must_be_available
    unless table_available?(table_number, start_time, end_time, id)
      errors.add(:table_number, "is already occupied during this time")
    end
  end

  def table_available?(table_number, start_time, end_time, id)
    Match.where(table_number: table_number)
         .where("start_time < ? AND end_time > ?", end_time, start_time)
         .where.not(id: id)
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
         .where("start_time < ? AND end_time > ?", end_time, start_time)
         .where.not(id: id)
         .none?
  end

  def adjust_wins
    wins_changed = false
    if winner_id_changed? && winner_id_was.present?
      previous_winner = Player.find_by(id: winner_id_was)
      previous_winner.decrement!(:wins) if previous_winner
      wins_changed = true if previous_winner
    end
    if winner_id.present?
      new_winner = Player.find_by(id: winner_id)
      new_winner.increment!(:wins) if new_winner
      wins_changed = true if new_winner
    end

    # Update player rankings if wins have changed
    UpdatePlayerRankingsJob.perform_later if wins_changed
  end

  def winner_is_valid
    if winner_id.present? && (winner_id != player1_id && winner_id != player2_id)
      errors.add("Winner must be one of the players")
    end
  end

  def players_are_different
    if player1_id == player2_id
      errors.add(:player2_id, "must be different from player1")
    end
  end

  def match_should_not_be_started
    if start_time < Time.zone.now
      errors.add("Match has already started")
      throw(:abort)
    end
  end
end
