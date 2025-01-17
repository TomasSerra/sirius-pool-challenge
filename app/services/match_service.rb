class MatchService
  def initialize(match_model: Match)
    @match_model = match_model
  end

  def get_all_matches(filters = {}, scope_mapping = {})
    Filters.new(@match_model.all, filters, scope_mapping).call
  end

  def get_match(id)
    @match_model.find_by(id: id)
  end

  def create_match(match_params)
    @match_model.create!(match_params)
    rescue => e
      raise StandardError, "Match creation failed: #{e.message}"
  end

  def update_match(match, match_params)
    return nil unless match

    if match.update(match_params)
      match
    else
      raise StandardError, "Match update failed: #{match.errors.full_messages.join(', ')}"
    end
  end

  def delete_match(match)
    return false unless match

    match.destroy
  end
end
