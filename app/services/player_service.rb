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

  def create_player(player_data)
    execute_with_error_handling do
      player_data[:ranking] ||= 0
      player_data[:wins] ||= 0

      image_name = SecureRandom.uuid
      path = "profile_pictures/#{image_name}"

      blob_data = generate_presigned_url(path, image_name)
      public_url = blob_data[:public_url]

      player_data[:profile_picture_url] = public_url

      player = @player_model.create!(player_data)

      { player: player, presigned_url: blob_data[:presigned_url] }
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
      if player && player[:profile_picture_url]
        path = URI.parse(player[:profile_picture_url]).path.sub(%r{^/[^/]+/}, "")
        filename = path.split("/").last
        generate_presigned_url(path, filename)[:presigned_url]
      else
        raise HttpErrors::NotFoundError.new("Profile picture URL not found for player #{player_id}")
      end
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

    { presigned_url: blob.service_url_for_direct_upload(expires_in: expiration_time), public_url: blob.url }
  end

  def get_presigned_url(path, expiration_time = 10.minute)
    blob = ActiveStorage::Blob.find_by(key: path)
    blob.url(expires_in: expiration_time, disposition: "inline") if blob
  end
end
