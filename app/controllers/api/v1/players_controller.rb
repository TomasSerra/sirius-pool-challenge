module Api
  module V1
    class PlayersController < ApplicationController
      include ActiveStorage::SetCurrent
      before_action :set_time_zone, only: [ :index, :show, :create, :update, :destroy ]

      def initialize(player_service: PlayerService.new)
        @player_service = player_service
      end

      def index
        filters = params.slice(:name, :order)
        scope_mapping = {
          name: :by_name,
          order: :order_by
        }
        players = @player_service.get_all_players(filters, scope_mapping)
        serialized_players = ActiveModelSerializers::SerializableResource.new(players, each_serializer: PlayerSerializer)
        render json: { data: { players: serialized_players } }, status: :ok
      rescue => e
        render_error(e)
      end

      def show
        player = @player_service.get_player(params[:id])
        serialized_player = PlayerSerializer.new(player).serializable_hash
        render json: { data: { player: serialized_player } }, status: :ok
      rescue => e
        render_error(e)
      end

      def create
        response = @player_service.create_player(player_params)
        serialized_player = PlayerSerializer.new(response[:player]).serializable_hash
        render json: { data: { player: serialized_player, presigned_url: response[:presigned_url] } }, status: :created
      rescue => e
        render_error(e)
      end

      def update
        player = @player_service.update_player(params[:id], player_params)
        serialized_player = PlayerSerializer.new(player).serializable_hash
        render json: { data: { player: serialized_player } }, status: :ok
      rescue => e
        render_error(e)
      end

      def destroy
        @player_service.delete_player(params[:id])
        head :no_content
      rescue => e
        render_error(e)
      end

      def update_profile_picture
        presigned_url = @player_service.get_new_pp_presigned_url(params[:id])
        render json: { data: { presigned_url: presigned_url } }, status: :ok
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
        elsif error.is_a?(ActionController::ParameterMissing)
          render json: {
            error: {
              code: "bad_request",
              message: "Required parameter is missing: #{error.param}"
            }
          }, status: :bad_request
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

      def player_params
        params.require(:player).permit(:name, :preferred_cue, :ranking, :wins)
      end
    end
  end
end
