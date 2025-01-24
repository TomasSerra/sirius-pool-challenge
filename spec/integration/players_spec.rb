require 'swagger_helper'

RSpec.describe 'Players', type: :request, openapi: 'v1/swagger.yaml' do
  path '/api/v1/players' do
    get('List players') do
      tags 'Players'
      produces 'application/json'
      parameter name: :order, in: :query, type: :string, description: 'Order players by any field (e.g., "name", "-name", "ranking", "-ranking", etc)'
      parameter name: :name, in: :query, type: :string, description: 'Search players by partial name (e.g., "John")'

      let(:order) { nil }
      let(:name) { nil }
      let(:params) { { order: order, name: name }.compact }

      before do
        get '/api/v1/players', params: params
      end

      response(200, 'ok') do
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
                           preferred_cue: { type: :string },
                           created_at: { type: :string, format: 'date-time' },
                           updated_at: { type: :string, format: 'date-time' }
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
                           wins: { type: :integer },
                           profile_picture_url: { type: :string },
                           preferred_cue: { type: :string },
                           created_at: { type: :string, format: 'date-time' },
                           updated_at: { type: :string, format: 'date-time' }
                         },
                         required: %w[id name profile_picture_url]
                     },
                     presigned_url: { type: :string }
                   },
                   required: %w[player]
                 }
               }

        let(:player) { { name: 'Name', preferred_cue: 'Cue' } }
        run_test!
      end

      response(400, 'bad request') do
        schema type: :object,
               properties: {
                 error: {
                   type: :object,
                   properties: {
                     code: { type: :string },
                     message: { type: :string }
                   }
                 }
               }
        let(:player) { {} }
        run_test!
      end

      response(409, 'conflict') do
        schema type: :object,
               properties: {
                 error: {
                   type: :object,
                   properties: {
                     code: { type: :string },
                     message: { type: :string }
                   }
                 }
               }
        let(:player) { { preferred_cue: 'Cue' } }
        run_test!
      end

      response(500, 'internal server error') do
        schema type: :object,
               properties: {
                 error: {
                   type: :object,
                   properties: {
                     code: { type: :string },
                     message: { type: :string }
                   }
                 }
               }
        let(:player) { { name: 'Name', preferred_cue: 'Cue', active: false } }
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

      response(200, 'ok') do
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
                         wins: { type: :integer },
                         profile_picture_url: { type: :string },
                         preferred_cue: { type: :string },
                         created_at: { type: :string, format: 'date-time' },
                         updated_at: { type: :string, format: 'date-time' }
                       }
                     },
                     presigned_url: { type: :string }
                   }
                 }
               }
        let(:id) { player.id }
        run_test!
      end

      response(404, 'not found') do
        schema type: :object,
               properties: {
                 error: {
                   type: :object,
                   properties: {
                     code: { type: :string },
                     message: { type: :string }
                   }
                 }
               }
        let(:id) { 900 }
        run_test!
      end
    end

    put('Update player') do
      tags 'Players'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :player_params, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          ranking: { type: :integer },
          wins: { type: :integer },
          profile_picture_url: { type: :string },
          preferred_cue: { type: :string }
        }
      }

      let!(:player) { create(:player) }

      response(200, 'ok') do
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
                          wins: { type: :integer },
                          profile_picture_url: { type: :string },
                          preferred_cue: { type: :string },
                          created_at: { type: :string, format: 'date-time' },
                          updated_at: { type: :string, format: 'date-time' }
                        },
                        required: %w[id name profile_picture_url]
                      }
                    },
                    required: %w[player]
                  }
                }
        let(:id) { player.id }
        let(:player_params) do
          {
            name: 'Name Updated',
            ranking: 1,
            preferred_cue: 'Another Cue',
            wins: 1
          }
        end
        run_test!
      end

      response(404, 'not found') do
        schema type: :object,
               properties: {
                 error: {
                   type: :object,
                   properties: {
                     code: { type: :string },
                     message: { type: :string }
                   }
                 }
               }
        let(:id) { 900 }
        let(:player_params) do
          {
            name: 'Name Updated',
            ranking: 1,
            preferred_cue: 'Another Cue',
            wins: 1
          }
        end
        run_test!
      end

      response(500, 'internal server error') do
        schema type: :object,
               properties: {
                 error: {
                   type: :object,
                   properties: {
                     code: { type: :string },
                     message: { type: :string }
                   }
                 }
               }
        let(:id) { player.id }
        let(:player_params) do
          {
            name: 'Name Updated',
            active: false
          }
        end
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
        schema type: :object,
               properties: {
                 error: {
                   type: :object,
                   properties: {
                     code: { type: :string },
                     message: { type: :string }
                   }
                 }
               }
        let(:id) { 900 }
        run_test!
      end
    end
  end

  path('/api/v1/players/profile_picture/{id}') do
    get('Get new profile picture presigned url') do
      parameter name: :id, in: :path, type: :integer, description: 'Player ID'
      tags 'Players'
      produces 'application/json'

      let!(:player) { create(:player) }

      response(200, 'successful') do
        schema type: :object,
                properties: {
                  data: {
                    type: :object,
                    properties: {
                      presigned_url: { type: :string }
                    }
                  }
                }
        let(:id) { player.id }
        run_test!
      end

      response(404, 'not found') do
        schema type: :object,
               properties: {
                 error: {
                   type: :object,
                   properties: {
                     code: { type: :string },
                     message: { type: :string }
                   }
                 }
               }
        let(:id) { 900 }
        run_test!
      end
    end
  end
end
