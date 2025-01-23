module Api
  module V1
    class MatchesController < ApplicationController
      before_action :set_time_zone, only: [ :index, :show, :create, :update, :destroy ]

      def initialize(match_service: MatchService.new)
        @match_service = match_service
      end

      def index
        filters = params.slice(:date, :status, :order)
        scope_mapping = {
          date: :by_date,
          status: :with_status,
          order: :order_by
        }
        matches = @match_service.get_all_matches(filters, scope_mapping)
        serialized_matches = ActiveModelSerializers::SerializableResource.new(matches, each_serializer: MatchSerializer)
        render json: { data: { matches: serialized_matches } }, status: :ok
      rescue => e
        render_error(e)
      end

      def show
        match = @match_service.get_match(params[:id])
        serialized_match = MatchSerializer.new(match).serializable_hash
        render json: { data: { match: serialized_match } }, status: :ok
      rescue => e
        render_error(e)
      end

      def create
        match = @match_service.create_match(match_params)
        serialized_match = MatchSerializer.new(match).serializable_hash
        render json: { data: { match: serialized_match } }, status: :created
      rescue => e
        render_error(e)
      end

      def update
        new_match = @match_service.update_match(params[:id], match_params)
        serialized_match = MatchSerializer.new(new_match).serializable_hash
        render json: { data: { match: serialized_match } }, status: :ok
      rescue => e
        render_error(e)
      end

      def destroy
        @match_service.delete_match(params[:id])
        head :no_content
      rescue => e
        render_error(e)
      end

      private

      def render_error(error)
        if error.is_a?(HttpErrors::HTTPError)
          render json: {
            error: {
              code: error.error_code,
              message: error.message
            }
          }, status: error.status
        else
          render json: {
            error: {
              code: "internal_server_error",
              message: error.message
            }
          }, status: :internal_server_error
        end
      end

      def set_time_zone
        @time_zone = request.headers["TimeZone"] || "UTC"
        Time.zone = @time_zone
      end

      def match_params
        params.require(:match).permit(:player1_id, :player2_id, :start_time, :end_time, :winner_id, :table_number)
      end
    end
  end
end
