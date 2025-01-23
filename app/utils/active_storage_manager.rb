module ActiveStorageManager
  def generate_presigned_url(path, file_name, expiration_time = 10.minutes)
    blob = ActiveStorage::Blob.find_or_create_by!(key: path) do |new_blob|
      new_blob.filename = file_name
      new_blob.byte_size = 0
      new_blob.checksum = "no-checksum"
      new_blob.content_type = "image/png"
      new_blob.metadata = { identified: true }
    end

    { presigned_url: blob.service_url_for_direct_upload(expires_in: expiration_time), public_url: blob.url }
  end
end
