class MatchService
  def initialize(match_class: Match)
    @match_class = match_class
  end

  def get_all_matches
    @match_class.all
  end

  def get_match(id)
    @match_class.find_by(id: id)
  end

  def create_match(match_params)
    @match_class.create!(match_params)
  rescue ActiveRecord::RecordInvalid => e
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