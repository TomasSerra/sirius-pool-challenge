require 'swagger_helper'

RSpec.describe 'Matches', type: :request, openapi: 'v1/swagger.yaml' do
  let!(:player1) { create(:player) }
  let!(:player2) { create(:player) }
  let!(:match) do
    create(:match,
           player1_id: player1.id,
           player2_id: player2.id,
           winner_id: player1.id)
  end
  path '/api/v1/matches' do
    get('List matches') do
      tags 'Matches'
      produces 'application/json'

      response(200, 'successful') do
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
                           table_number: { type: :integer }
                         },
                         required: %w[id player1_id player2_id start_time table_number]
                       }
                     }
                   },
                   required: %w[matches]
                 }
               }

        run_test!
      end
    end

    post('Create match') do
      tags 'Matches'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :match, in: :body, schema: {
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
                           table_number: { type: :integer }
                         },
                         required: %w[id player1_id player2_id start_time table_number]
                     }
                   },
                   required: %w[matches]
                 }
               }
        let(:match) { { player1_id: player1.id, player2_id: player2.id, start_time: Time.now, end_time: Time.now + 1.hour, table_number: 1 } }
        run_test!
      end

      response(422, 'unprocessable entity') do
        let(:match) { { table_number: 2 } }
        run_test!
      end
    end
  end

  path '/api/v1/matches/{id}' do
    parameter name: :id, in: :path, type: :bigint, description: 'Match ID'

    get('Show match') do
      tags 'Matches'
      produces 'application/json'

      response(200, 'successful') do
        let(:id) { match.id }
        run_test!
      end

      response(404, 'not found') do
        let(:id) { 0 }
        run_test!
      end
    end

    put('Update match') do
      tags 'Matches'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :match, in: :body, schema: {
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

      response(200, 'successful') do
        let(:id) { match.id }
        run_test!
      end

      response(404, 'not found') do
        let(:id) { 0 }
        run_test!
      end
    end

    delete('Delete match') do
      tags 'Matches'

      response(204, 'no content') do
        let(:id) { match.id }
        run_test!
      end

      response(404, 'not found') do
        let(:id) { 0 }
        run_test!
      end
    end
  end
end
