require "securerandom"

class StorageService
  def initialize(active_storage: ActiveStorage::Blob.service)
    @active_storage = active_storage
  end

  def generate_presigned_url(folder_name, expiration_time = 60)
    formatted_folder_name = format_folder_name(folder_name)

    path = "#{formatted_folder_name}/#{SecureRandom.uuid}"

    @active_storage.service_url(path, expires_in: expiration_time, disposition: "attachment")
  rescue StandardError => e
    Rails.logger.error("Error generating presigned URL: #{e.message}")
    nil
  end

  private

  def format_folder_name(folder_name)
    folder_name.gsub(/[^a-zA-Z0-9_\-\/]/, "_")
  end
end
