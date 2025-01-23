module HttpErrors
  class HTTPError < StandardError
    attr_reader :status, :error_code, :message

    def initialize(status: 500, error_code: "internal_server_error", message: "An error occurred")
      @status = status
      @error_code = error_code
      @message = message
      super(format_message(message))
    end

    private

    def format_message(message)
      message.gsub("\n", " ").gsub("\r", "")
    end
  end

  class BadRequestError < HTTPError
    def initialize(message = "Bad Request")
      super(status: 400, error_code: "bad_request", message: message)
    end
  end

  class UnauthorizedError < HTTPError
    def initialize(message = "Unauthorized")
      super(status: 401, error_code: "unauthorized", message: message)
    end
  end

  class ForbiddenError < HTTPError
    def initialize(message = "Forbidden")
      super(status: 403, error_code: "forbidden", message: message)
    end
  end

  class NotFoundError < HTTPError
    def initialize(message = "Not Found")
      super(status: 404, error_code: "not_found", message: message)
    end
  end

  class ConflictError < HTTPError
    def initialize(message = "Conflict")
      super(status: 409, error_code: "conflict", message: message)
    end
  end

  class UnprocessableEntityError < HTTPError
    def initialize(message = "Unprocessable Entity")
      super(status: 422, error_code: "unprocessable_entity", message: message)
    end
  end

  class InternalServerError < HTTPError
    def initialize(message = "Internal Server Error")
      super(status: 500, error_code: "internal_server_error", message: message)
    end
  end
end
