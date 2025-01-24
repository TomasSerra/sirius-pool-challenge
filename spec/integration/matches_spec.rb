require 'swagger_helper'

RSpec.describe 'Matches', type: :request, openapi: 'v1/swagger.yaml' do
  let!(:player1) { create(:player) }
  let!(:player2) { create(:player) }
  let!(:match) do
    create(:match,
           player1_id: player1.id,
           player2_id: player2.id,
           start_time: "2010-01-17T04:00:00.0Z",
           end_time: "2010-01-17T05:00:00.0Z",
           winner_id: player1.id)
  end
  let!(:match2) do
    create(:match,
           player1_id: player1.id,
           player2_id: player2.id,
           start_time: "2011-01-17T04:00:00.0Z",
           end_time: "2011-01-17T05:00:00.0Z",
           winner_id: player1.id)
  end
  path '/api/v1/matches' do
    get('List matches') do
      tags 'Matches'
      produces 'application/json'

      parameter name: :order, in: :query, type: :string, description: 'Order matches by any field (e.g., "start_time", "-start_time", "end_time", "-end_time", etc.)'
      parameter name: :date, in: :query, type: :string, format: 'date', description: 'Filter matches by a specific date (e.g., "2025-01-21")'
      parameter name: :status, in: :query, type: :string, description: 'Filter matches by status (e.g., "completed", "ungoing", "upcoming")'
      let(:order) { nil }
      let(:date) { nil }
      let(:status) { nil }
      let(:params) { { order: order, date: date, status: status }.compact }

      before do
        get '/api/v1/matches', params: params
      end

      response(200, 'ok') do
        schema type: :object,
               properties: {
                 data: {
                   type: :object,
                   properties: {
                     matches: {
                       type: :array,
                       items: {
                         type: :object,
                         properties: {
                           id: { type: :integer },
                           player1_id: { type: :integer },
                           player2_id: { type: :integer },
                           start_time: { type: :string, format: 'date-time' },
                           end_time: { type: :string, format: 'date-time' },
                           winner_id: { type: :integer, nullable: true },
                           table_number: { type: :integer },
                           created_at: { type: :string, format: 'date-time' },
                           updated_at: { type: :string, format: 'date-time' }
                         }
                       }
                     }
                   }
                 }
               }

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
      end
    end

    post('Create match') do
      tags 'Matches'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :match_params, in: :body, schema: {
        type: :object,
        properties: {
          player1_id: { type: :integer },
          player2_id: { type: :integer },
          start_time: { type: :string, format: 'date-time' },
          end_time: { type: :string, format: 'date-time' },
          winner_id: { type: :integer, nullable: true },
          table_number: { type: :integer }
        },
        required: %w[player1_id player2_id start_time table_number]
      }

      response(201, 'created') do
        schema type: :object,
               properties: {
                 data: {
                   type: :object,
                   properties: {
                     match: {
                       type: :object,
                       properties: {
                           id: { type: :integer },
                           player1_id: { type: :integer },
                           player2_id: { type: :integer },
                           start_time: { type: :string, format: 'date-time' },
                           end_time: { type: :string, format: 'date-time' },
                           winner_id: { type: :integer, nullable: true },
                           table_number: { type: :integer },
                           created_at: { type: :string, format: 'date-time' },
                           updated_at: { type: :string, format: 'date-time' }
                         }
                     }
                   }
                 }
               }
        let(:match_params) { { player1_id: player1.id, player2_id: player2.id, start_time: Time.now, end_time: Time.now + 1.hour, table_number: 1 } }
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
        let(:match_params) { { player1_id: player1.id, player2_id: player2.id, start_time: Time.now, table_number: 1, winner_id: player1.id + player2.id } }
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
        let(:match_params) { { player1_id: player1.id, player2_id: player2.id, start_time: "2010-01-17T04:00:00.0Z", end_time: "2010-01-17T05:00:00.0Z", table_number: 1 } }
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
      end
    end
  end

  path '/api/v1/matches/{id}' do
    parameter name: :id, in: :path, type: :integer, description: 'Match ID'

    get('Show match') do
      tags 'Matches'
      produces 'application/json'

      response(200, 'ok') do
        schema type: :object,
               properties: {
                 data: {
                   type: :object,
                   properties: {
                     match: {
                       type: :object,
                       properties: {
                         id: { type: :integer },
                         player1_id: { type: :integer },
                         player2_id: { type: :integer },
                         start_time: { type: :string, format: 'date-time' },
                         end_time: { type: :string, format: 'date-time' },
                         winner_id: { type: :integer, nullable: true },
                         table_number: { type: :integer },
                         created_at: { type: :string, format: 'date-time' },
                         updated_at: { type: :string, format: 'date-time' }
                       }
                     }
                   }
                 }
               }
        let(:id) { match.id }
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
        let(:id) { 0 }
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
      end
    end

    put('Update match') do
      tags 'Matches'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :match_params, in: :body, schema: {
        type: :object,
        properties: {
          player1_id: { type: :integer },
          player2_id: { type: :integer },
          start_time: { type: :string, format: 'date-time' },
          end_time: { type: :string, format: 'date-time' },
          winner_id: { type: :integer, nullable: true },
          table_number: { type: :integer }
        }
      }

      response(200, 'ok') do
        schema type: :object,
               properties: {
                 data: {
                   type: :object,
                   properties: {
                     match: {
                       type: :object,
                       properties: {
                           id: { type: :integer },
                           player1_id: { type: :integer },
                           player2_id: { type: :integer },
                           start_time: { type: :string, format: 'date-time' },
                           end_time: { type: :string, format: 'date-time' },
                           winner_id: { type: :integer, nullable: true },
                           table_number: { type: :integer },
                           created_at: { type: :string, format: 'date-time' },
                           updated_at: { type: :string, format: 'date-time' }
                       }
                     }
                   }
                 }
               }
        let(:id) { match.id }
        let(:match_params) { { player1_id: player1.id, player2_id: player2.id, start_time: Time.now, end_time: Time.now + 1.hour, table_number: 1 } }
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
        let(:id) { match.id }
        let(:match_params) { { player1_id: player1.id, player2_id: player2.id, start_time: Time.now, table_number: 1, winner_id: player1.id + player2.id } }
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
        let(:id) { 0 }
        let(:match_params) { { player1_id: player1.id, player2_id: player2.id, start_time: Time.now, end_time: Time.now + 1.hour, table_number: 1 } }
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
        let(:id) { match2.id }
        let(:match_params) { { player1_id: player1.id, player2_id: player2.id, start_time: "2010-01-17T04:00:00.0Z", end_time: "2010-01-17T05:00:00.0Z", table_number: 1 } }
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
      end
    end

    delete('Delete match') do
      tags 'Matches'

      let(:delete_match) do
        create(:match,
               player1_id: player1.id,
               player2_id: player2.id,
               start_time: "2500-01-17T04:00:00.0Z",
               end_time: "2500-01-17T05:00:00.0Z",
               winner_id: player1.id)
      end

      response(204, 'no content') do
        let(:id) { delete_match.id }
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
        let(:id) { 0 }
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
      end
    end
  end
end
