# app/services/match_service.rb
class MatchService
  include ErrorHandler

  def initialize(match_model: Match)
    @match_model = match_model
  end

  def get_all_matches(filters = {}, scope_mapping = {})
    execute_with_error_handling do
      Filters.new(@match_model.all, filters, scope_mapping).call
    end
  end

  def get_match(match_id)
    execute_with_error_handling do
      match = @match_model.find_by(id: match_id)
      raise HttpErrors::NotFoundError.new("Match not found with ID #{match_id}") if match.nil?
      match
    end
  end

  def create_match(match_params)
    execute_with_error_handling do
      @match_model.create!(match_params)
    end
  end

  def update_match(match_id, match_params)
    execute_with_error_handling do
      match = get_match(match_id)
      match.update!(match_params)
      match
    end
  end

  def delete_match(match_id)
    execute_with_error_handling do
      match = get_match(match_id)
      match.destroy!
    end
  end
end
