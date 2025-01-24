module ErrorHandler
  extend ActiveSupport::Concern

  private

  def execute_with_error_handling
    begin
      yield
    rescue ArgumentError => e
      raise HttpErrors::BadRequestError.new("Invalid argument: #{e.message}")
    rescue NoMethodError => e
      raise HttpErrors::BadRequestError.new("Invalid filter or scope method: #{e.message}")
    rescue ActiveRecord::StatementInvalid => e
      raise HttpErrors::BadRequestError.new("Invalid query: #{e.message}")
    rescue ActiveRecord::RecordNotFound => e
      raise HttpErrors::NotFoundError.new("Record not found: #{e.message}")
    rescue ActiveRecord::RecordInvalid => e
      raise HttpErrors::ConflictError.new("Validation failed: #{e.record.errors.full_messages.join('; ')}")
    rescue ActiveRecord::RecordNotUnique => e
      raise HttpErrors::ConflictError.new("Duplicate record: #{e.message}")
    rescue ActiveRecord::ConnectionNotEstablished => e
      raise HttpErrors::InternalServerError.new("Database connection error: #{e.message}")
    rescue ActiveRecord::NotNullViolation => e
      raise HttpErrors::UnprocessableEntityError.new("Null value not allowed: #{e.message}")
    rescue ActiveRecord::RecordNotDestroyed => e
      raise HttpErrors::InternalServerError.new("Failed to destroy record: #{e.record.errors.full_messages.join('; ')}}")
    rescue HttpErrors::NotFoundError => e
      raise e
    rescue => e
      raise HttpErrors::InternalServerError.new("Unexpected error: #{e.message}")
    end
  end
end
