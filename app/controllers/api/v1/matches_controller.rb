module Api
  module V1
    class MatchesController < ApplicationController
      before_action :set_match, only: [ :show, :update, :destroy ]

      def initialize(match_service: MatchService.new)
        @match_service = match_service
      end

      def index
        matches = @match_service.get_all_matches
        render json: { data: { matches: matches } }
      end

      def show
        render json: { data: { match: @match } }
      end

      def create
        match = @match_service.create_match(match_params)
        render json: { data: { match: match } }, status: :created
      rescue StandardError => e
        render json: { error: e.message }, status: :unprocessable_content
      end

      def update
        if @match_service.update_match(@match, match_params)
          render json: { data: { match: @match } }
        else
          render json: { error: "Could not update match" }, status: :unprocessable_content
        end
      end

      def destroy
        if @match_service.delete_match(@match)
          head :no_content
        else
          render json: { error: "Could not delete match" }, status: :unprocessable_content
        end
      end

      private

      def set_match
        @match = @match_service.get_match(params[:id])
        render json: { error: "Match not found" }, status: :not_found unless @match
      end

      def match_params
        params.require(:match).permit(:player1_id, :player2_id, :start_time, :end_time, :winner_id, :table_number)
      end
    end
  end
end