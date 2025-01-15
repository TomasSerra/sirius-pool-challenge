module Api
  module V1
    class PlayersController < ApplicationController
      before_action :set_player, only: [ :show, :update, :destroy ]

      def initialize(player_service: PlayerService.new)
        @player_service = player_service
      end

      def index
        players = @player_service.get_all_players
        render json: players
      end

      def show
        render json: @player
      end

      def create
        player = @player_service.create_player(player_params)

        if player.persisted?
          render json: player, status: :created
        else
          render json: { error: player.errors.messages }, status: :unprocessable_content
        end
      end

      def update
        if @player_service.update_player(@player, player_params)
          render json: @player
        else
          render json: { error: "Could not update player" }, status: :unprocessable_content
        end
      end

      def destroy
        if @player_service.delete_player(@player)
          head :no_content
        else
          render json: { error: "Could not delete player" }, status: :unprocessable_content
        end
      end

      private

      def set_player
        @match = @player_service.get_player(params[:id])
        render json: { error: "Player not found" }, status: :not_found unless @player
      end

      def player_params
        params.require(:player).permit(:name, :profile_picture_url, :ranking, :preferred_cue)
      end
    end
  end
end
