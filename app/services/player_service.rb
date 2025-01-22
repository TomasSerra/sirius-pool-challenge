class PlayerService
  include ErrorHandler

  def initialize(player_model: Player)
    @player_model = player_model
  end

  def get_all_players(filters = {}, scope_mapping = {})
    execute_with_error_handling do
      Filters.new(@player_model.all, filters, scope_mapping).call
    end
  end

  def get_player(id)
    execute_with_error_handling do
      player = @player_model.find_by(id: id)
      raise HttpErrors::NotFoundError.new("Player not found with ID #{id}") if player.nil?
      player
    end
  end

  def get_player_with_pp(id)
    execute_with_error_handling do
      player = get_player(id)
      profile_picture_url = player[:profile_picture_url] if player
      player[:profile_picture_url] = get_presigned_url(profile_picture_url) if player
      player
    end
  end

  def create_player(player_data)
    execute_with_error_handling do
      player_data[:ranking] ||= 0
      player_data[:wins] ||= 0
      image_name = SecureRandom.uuid
      path = "profile_pictures/#{image_name}"
      pp_image_url = generate_presigned_url(path, image_name)
      player_data[:profile_picture_url] = path
      player = @player_model.create!(player_data)
      { player: player, presigned_url: pp_image_url }
    end
  end

  def update_player(player_id, player_params)
    execute_with_error_handling do
      player = get_player(player_id)
      player.update!(player_params)
      player
    end
  end

  def delete_player(player_id)
    execute_with_error_handling do
      player = get_player(player_id)
      player.update!(active: false)
    end
  end

  def get_new_pp_presigned_url(player_id)
    execute_with_error_handling do
      player = get_player(player_id)
      path = player[:profile_picture_url] if player
      filename = path.split("/").last if path
      generate_presigned_url(path, filename)
    end
  end

  private

  def generate_presigned_url(path, file_name, expiration_time = 10.minute)
    blob = ActiveStorage::Blob.find_or_create_by!(key: path) do |new_blob|
      new_blob.filename = file_name
      new_blob.byte_size = 0
      new_blob.checksum = "no-checksum"
      new_blob.content_type = "image/png"
      new_blob.metadata = { identified: true }
    end

    blob.service_url_for_direct_upload(expires_in: expiration_time)
  end

  def get_presigned_url(path, expiration_time = 10.minute)
    blob = ActiveStorage::Blob.find_by(key: path)
    blob.url(expires_in: expiration_time, disposition: "inline") if blob
  end
end
