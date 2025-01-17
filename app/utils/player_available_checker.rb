class PlayerAvailabilityChecker
  def initialize(player_id, start_time, end_time)
    @player_id = player_id
    @start_time = start_time
    @end_time = end_time
  end

  def available?
    Match.where(player1_id: @player_id)
         .or(Match.where(player2_id: @player_id))
         .where('start_time < ? AND end_time > ?', @end_time, @start_time)
         .none?
  end
end