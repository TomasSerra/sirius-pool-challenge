class Filters
  def initialize(scope, filters, scope_mapping)
    @scope = scope
    @filters = filters
    @scope_mapping = scope_mapping
  end

  def call
    apply_filters
  end

  private

  def apply_filters
    @filters.each do |key, value|
      scope_method = @scope_mapping[key.to_sym]
      if value.present? && @scope.respond_to?(scope_method)
        @scope = @scope.public_send(scope_method, value)
      end
    end
    @scope
  end
end
