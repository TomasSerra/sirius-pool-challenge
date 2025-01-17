class PlayerService
  def initialize(player_model: Player)
    @player_model = player_model
  end

  def get_all_players(filters = {}, scope_mapping = {})
    Filters.new(@player_model.all, filters, scope_mapping).call
  end

  def get_player(id)
    @player_model.find_by(id: id)
  end

  def create_player(player_data)
    player_data[:ranking] ||= 0
    image_name = SecureRandom.uuid
    pp_image_url = generate_presigned_url("profile_pictures", image_name)
    player_data[:profile_picture_url] = "profile_pictures/#{image_name}"
    player = @player_model.create!(player_data)
    { player: player, presigned_url: pp_image_url }
  rescue ActiveRecord::RecordInvalid => e
    raise StandardError, "Player creation failed: #{e.message}"
  end

  def update_player(id, player_params)
    player = get_player(id)
    return nil unless player

    if player.update(player_params)
      player
    else
      raise StandardError, "Player update failed: #{player.errors.full_messages.join(', ')}"
    end
  end

  def delete_player(id)
    player = get_player(id)
    return false unless player
    if player.update(active: false)
      player
    else
      raise StandardError, "Player delete failed: #{player.errors.full_messages.join(', ')}"
    end
  end

  private

  def generate_presigned_url(folder_name, file_name, expiration_time = 10.minute)
    path = "#{folder_name}/#{file_name}"

    blob = ActiveStorage::Blob.create_before_direct_upload!(
      key: path,
      filename: file_name,
      byte_size: 0,
      checksum: "no-checksum",
      content_type: "application/octet-stream",
      metadata: { identified: true }
    )

    blob.service_url_for_direct_upload(expires_in: expiration_time)
  end
end
