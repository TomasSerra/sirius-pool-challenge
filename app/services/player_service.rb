class PlayerService
  def initialize(player_class: Player)
    @player_class = player_class
  end

  def get_all_players
    @player_class.all
  end

  def get_player(id)
    @player_class.find_by(id: id)
  end

  def create_player(player_params)
    @player_class.create!(player_params)
  rescue ActiveRecord::RecordInvalid => e
    raise StandardError, "Player creation failed: #{e.message}"
  end

  def update_player(id, player_params)
    player = @player_class.find_by(id: id)
    return nil unless player

    if player.update(player_params)
      player
    else
      raise StandardError, "Player update failed: #{player.errors.full_messages.join(', ')}"
    end
  end

  def delete_player(id)
    player = @player_class.find_by(id: id)
    return false unless player

    player.destroy
  end
end
