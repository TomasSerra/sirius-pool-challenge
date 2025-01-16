require 'swagger_helper'

RSpec.describe 'Players', type: :request, openapi: 'v1/swagger.yaml' do
  path '/api/v1/players' do
    get('List players') do
      tags 'Players'
      produces 'application/json'

      response(200, 'successful') do
        schema type: :object,
               properties: {
                 data: {
                   type: :object,
                   properties: {
                     players: {
                       type: :array,
                       items: {
                         type: :object,
                         properties: {
                           id: { type: :integer },
                           name: { type: :string },
                           ranking: { type: :integer },
                           profile_picture_url: { type: :string },
                           preferred_cue: { type: :string }
                         },
                         required: %w[id name profile_picture_url]
                       }
                     }
                   },
                    required: %w[players]
                  }
                }

        run_test!
      end
    end

    post('Create player') do
      tags 'Players'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :player, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          ranking: { type: :integer },
          profile_picture_url: { type: :string },
          preferred_cue: { type: :string }
        },
        required: %w[name profile_picture_url]
      }

      response(201, 'created') do
        schema type: :object,
               properties: {
                 data: {
                   type: :object,
                   properties: {
                     player: {
                         type: :object,
                         properties: {
                           id: { type: :integer },
                           name: { type: :string },
                           ranking: { type: :integer },
                           profile_picture_url: { type: :string },
                           preferred_cue: { type: :string }
                         },
                         required: %w[id name profile_picture_url]
                     },
                     presigned_url: { type: :string }
                   },
                   required: %w[players]
                 }
               }

        let!(:player) { create(:player, :with_name_and_preferred_cue) }
        run_test!
      end

      response(422, 'unprocessable entity') do
        let(:player) { { name: '' } }
        run_test!
      end
    end
  end

  path '/api/v1/players/{id}' do
    parameter name: :id, in: :path, type: :integer, description: 'Player ID'

    get('Show player') do
      tags 'Players'
      produces 'application/json'

      let!(:player) { create(:player) }

      response(200, 'successful') do
        let(:id) { player.id }
        run_test!
      end

      response(404, 'not found') do
        let(:id) { 900 }
        run_test!
      end
    end

    put('Update player') do
      tags 'Players'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :player, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          ranking: { type: :integer },
          profile_picture_url: { type: :string },
          preferred_cue: { type: :string }
        }
      }

      let!(:player) { create(:player) }

      response(200, 'successful') do
        let(:id) { player.id }
        let(:player_params) do
          {
            name: 'Name Updated',
            ranking: 1,
            preferred_cue: 'Another Cue'
          }
        end
        run_test!
      end

      response(404, 'not found') do
        let(:id) { 900 }
        let(:player_params) do
          {
            name: 'Name Updated',
            ranking: 1,
            preferred_cue: 'Another Cue'
          }
        end
        run_test!
      end
    end

    delete('Delete player') do
      tags 'Players'

      let!(:player) { create(:player) }

      response(204, 'no content') do
        let(:id) { player.id }
        run_test!
      end

      response(404, 'not found') do
        let(:id) { 900 }
        run_test!
      end
    end
  end
end
