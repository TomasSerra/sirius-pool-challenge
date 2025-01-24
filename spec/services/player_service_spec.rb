require 'rails_helper'

RSpec.describe PlayerService, type: :service do
  let(:player_service) { PlayerService.new }

  let!(:player1) { create(:player, name: 'John Doe', wins: 10) }
  let!(:player2) { create(:player, name: 'Jane Doe', wins: 20) }
  let!(:player3) { create(:player, name: 'Alice', wins: 30) }
  let!(:player4) { create(:player, name: 'Bob', wins: 5, active: false) }

  describe '#get_all_players' do
    let(:scope_mapping) { { name: :by_name, order: :order_by } }

    it 'returns all active players successfully' do
      filters = {}
      expect(player_service.get_all_players(filters, scope_mapping)).to eq([ player1, player2, player3 ])
    end

    it 'filters players by name=Al successfully' do
      filters = { name: 'Al' }
      expect(player_service.get_all_players(filters, scope_mapping)).to eq([ player3 ])
    end

    it 'filters players by name=J successfully' do
      filters = { name: 'J' }
      expect(player_service.get_all_players(filters, scope_mapping)).to eq([ player1, player2 ])
    end

    it 'orders players by ranking desc successfully' do
      filters = { order: '-ranking' }
      expect(player_service.get_all_players(filters, scope_mapping)).to eq([ player3, player2, player1 ])
    end

    it 'orders players by ranking asc successfully' do
      filters = { order: 'ranking' }
      expect(player_service.get_all_players(filters, scope_mapping)).to eq([ player1, player2, player3 ])
    end

    it 'throws error when invalid filter' do
      filters = { invalid: 'invalid' }
      expect { player_service.get_all_players(filters, scope_mapping) }.to raise_error(HttpErrors::InternalServerError)
    end
  end

  describe '#get_player' do
    it 'returns the player successfully' do
      expect(player_service.get_player(player1.id)).to eq(player1)
    end

    it 'throws error when player not found' do
      expect { player_service.get_player(0) }.to raise_error(HttpErrors::NotFoundError)
    end
  end

  describe '#create_player' do
    it 'creates a player successfully' do
      player_params = { name: 'Charlie', preferred_cue: 'Custom Cue' }
      response = player_service.create_player(player_params)
      expect(response[:player]).to be_instance_of(Player)
      expect(response[:presigned_url]).not_to be_nil
    end

    it 'throws error when name is empty' do
      player_params = { name: "" }
      expect { player_service.create_player(player_params) }.to raise_error(HttpErrors::ConflictError)
    end
  end

  describe '#update_player' do
    it 'updates the player successfully' do
      player_params = { name: 'Changed name' }
      updated_player = player_service.update_player(player1.id, player_params)
      expect(updated_player.name).to eq('Changed name')
    end

    it 'throws error when player not found' do
      player_params = { name: 'Changed name' }
      expect { player_service.update_player(0, player_params) }.to raise_error(HttpErrors::NotFoundError)
    end

    it 'throws error when invalid param' do
      player_params = { invalid: "invalid" }
      expect { player_service.update_player(player1.id, player_params) }.to raise_error(HttpErrors::BadRequestError)
    end
  end

  describe '#delete_player' do
    it 'deactivates the player successfully' do
      player_service.delete_player(player1.id)
      expect(player1.reload.active).to eq(false)
    end

    it 'throws error when player not found' do
      expect { player_service.delete_player(0) }.to raise_error(HttpErrors::NotFoundError)
    end
  end

  describe '#get_new_pp_presigned_url' do
    it 'returns a presigned URL for updating the profile picture' do
      presigned_url = player_service.get_new_pp_presigned_url(player1.id)
      expect(presigned_url).to be_a(String)
    end

    it 'throws error when player is not found' do
      expect { player_service.get_new_pp_presigned_url(0) }.to raise_error(HttpErrors::NotFoundError)
    end
  end
end
