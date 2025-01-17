module Api
  module V1
    class PlayersController < ApplicationController
      before_action :set_player, only: [ :show, :update, :destroy ]

      def initialize(player_service: PlayerService.new)
        @player_service = player_service
      end

      def index
        filters = params.slice(:name)
        scope_mapping = {
          name: :by_name
        }
        players = @player_service.get_all_players(filters, scope_mapping)
        render json: { data: { players: players } }
      end

      def show
        render json: { data: { player: @player } }
      end

      def create
        response = @player_service.create_player(player_params)
        render json: { data: response }, status: :created
      rescue StandardError => e
        render json: { error: e.message }, status: :unprocessable_content
      end

      def update
        player = @player_service.update_player(@player, player_params)
        render json: { data: { player: player } }
      rescue StandardError => e
        render json: { error: e.message }, status: :unprocessable_content
      end

      def destroy
        if @player_service.delete_player(@player)
          head :no_content
        else
          render json: { error: "Could not delete player" }, status: :unprocessable_content
        end
      rescue StandardError => e
        render json: { error: e.message }, status: :unprocessable_content
      end

      private

      def set_player
        @player = @player_service.get_player(params[:id])
        render json: { error: "Player not found" }, status: :not_found unless @player
      end

      def player_params
        params.require(:player).permit(:name, :preferred_cue, :ranking, :profile_picture_url)
      end
    end
  end
end
