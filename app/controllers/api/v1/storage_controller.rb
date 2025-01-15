module Api
  module V1
    class StorageController < ApplicationController
      def generate_presigned_url
        folder_name = params[:folder_name]

        presigned_url = StorageService.new.generate_presigned_url(folder_name)

        render json: { url: presigned_url }, status: :ok
      rescue StandardError => e
        render json: { error: e.message }, status: :unprocessable_content
      end

      private

      def storage_params
        params.require(:storage).permit(:blob_name)
      end
    end
  end
end
