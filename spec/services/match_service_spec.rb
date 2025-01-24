require 'rails_helper'

RSpec.describe MatchService, type: :service do
  let(:match_service) { MatchService.new }

  let!(:player1) { create(:player) }
  let!(:player2) { create(:player) }
  let!(:player3) { create(:player) }
  let!(:player4) { create(:player) }

  let!(:match1) { create(:match, start_time: "2010-01-20T17:00:00.000Z", end_time: "2010-01-20T18:00:00.000Z", player1_id: player1.id, player2_id: player2.id, table_number: 10) }
  let!(:match2) { create(:match, start_time: "2011-01-20T17:00:00.000Z", end_time: "2011-01-20T18:00:00.000Z", player1_id: player1.id, player2_id: player2.id, table_number: 10) }
  let!(:match3) { create(:match, start_time: "2500-01-20T17:00:00.000Z", end_time: "2500-01-20T18:00:00.000Z", player1_id: player1.id, player2_id: player2.id, table_number: 10) }
  let!(:match4) { create(:match, start_time: Time.now, end_time: Time.now + 1.hour, player1_id: player1.id, player2_id: player2.id, table_number: 10) }

  describe "#get_all_matches" do
    let(:scope_mapping) { { date: :by_date, status: :with_status, order: :order_by } }

    it "returns all matches successfully" do
      filters = {}
      expect(match_service.get_all_matches(filters, scope_mapping)).to eq([ match1, match2, match3, match4 ])
    end

    it "filters matches by date=2010-01-20 successfully" do
      filters = { date: "2010-01-20" }
      expect(match_service.get_all_matches(filters, scope_mapping)).to eq([ match1 ])
    end

    it "filters matches by status=upcoming successfully" do
      filters = { status: "upcoming" }
      expect(match_service.get_all_matches(filters, scope_mapping)).to eq([ match3 ])
    end

    it "filters matches by status=ongoing successfully" do
      filters = { status: "ongoing" }
      expect(match_service.get_all_matches(filters, scope_mapping)).to eq([ match4 ])
    end

    it "filters matches by status=completed successfully" do
      filters = { status: "completed" }
      expect(match_service.get_all_matches(filters, scope_mapping)).to eq([ match1, match2 ])
    end

    it "orders matches by start_time asc successfully" do
      filters = { order: "start_time" }
      expect(match_service.get_all_matches(filters, scope_mapping)).to eq([ match1, match2, match4, match3 ])
    end

    it "orders matches by start_time desc successfully" do
      filters = { order: "-start_time" }
      expect(match_service.get_all_matches(filters, scope_mapping)).to eq([ match3, match4, match2, match1 ])
    end

    it "filters matches by date and status=upcoming successfully" do
      filters = { date: "2500-01-20", status: "upcoming" }
      expect(match_service.get_all_matches(filters, scope_mapping)).to eq([ match3 ])
    end

    it "filters matches by status=complete and order by start_time asc successfully" do
      filters = { status: "completed", order: "start_time" }
      expect(match_service.get_all_matches(filters, scope_mapping)).to eq([ match1, match2 ])
    end

    it "throws error when invalid filter" do
      filters = { invalid: "invalid" }
      expect { match_service.get_all_matches(filters, scope_mapping) }.to raise_error(HttpErrors::InternalServerError)
    end
  end

  describe "#get_match" do
    it "returns the match successfully" do
      expect(match_service.get_match(match1.id)).to eq(match1)
    end

    it "throws error when match not found" do
      expect { match_service.get_match(0) }.to raise_error(HttpErrors::NotFoundError)
    end
  end

  describe "#create_match" do
    it "creates a match successfully" do
      match_params = { start_time: "2400-01-20T17:00:00.000Z", end_time: "2400-01-20T18:00:00.000Z", player1_id: player1.id, player2_id: player2.id, table_number: 10 }
      expect(match_service.create_match(match_params)).to be_instance_of(Match)
    end

    it "throws error when table_number is null" do
      match_params = { start_time: "2400-01-20T17:00:00.000Z", end_time: "2400-01-20T18:00:00.000Z", player1_id: player1.id, player2_id: player2.id }
      expect { match_service.create_match(match_params) }.to raise_error(HttpErrors::ConflictError)
    end

    it "throws error when table_number is already occupied" do
      match_params = { start_time: "2500-01-20T17:00:00.000Z", end_time: "2500-01-20T18:00:00.000Z", player1_id: player3.id, player2_id: player4.id, table_number: 10 }
      expect { match_service.create_match(match_params) }.to raise_error(HttpErrors::ConflictError)
    end

    it "throws error when player1 is not available" do
      match_params = { start_time: "2500-01-20T17:00:00.000Z", end_time: "2500-01-20T18:00:00.000Z", player1_id: player1.id, player2_id: player3.id, table_number: 20 }
      expect { match_service.create_match(match_params) }.to raise_error(HttpErrors::ConflictError)
    end

    it "throws error when player2 is not available" do
      match_params = { start_time: "2500-01-20T17:00:00.000Z", end_time: "2500-01-20T18:00:00.000Z", player1_id: player3.id, player2_id: player2.id, table_number: 20 }
      expect { match_service.create_match(match_params) }.to raise_error(HttpErrors::ConflictError)
    end

    it "throws error when start_time is later than end_time" do
      match_params = { start_time: "2500-01-20T18:00:00.000Z", end_time: "2500-01-20T17:00:00.000Z", player1_id: player3.id, player2_id: player4.id, table_number: 20 }
      expect { match_service.create_match(match_params) }.to raise_error(HttpErrors::ConflictError)
    end

    it "throws error when start_time is equal to end_time" do
      match_params = { start_time: "2500-01-20T18:00:00.000Z", end_time: "2500-01-20T18:00:00.000Z", player1_id: player3.id, player2_id: player4.id, table_number: 20 }
      expect { match_service.create_match(match_params) }.to raise_error(HttpErrors::ConflictError)
    end

    it "throws error when start_time is nil" do
      match_params = { end_time: "2500-01-20T18:00:00.000Z", player1_id: player3.id, player2_id: player4.id, table_number: 20 }
      expect { match_service.create_match(match_params) }.to raise_error(HttpErrors::ConflictError)
    end
  end

  describe "#update_match" do
    it "updates the match start_time, end_time, player1_id,  successfully" do
      match_params = { start_time: "2400-01-20T17:00:00.000Z", end_time: "2400-01-20T18:00:00.000Z", player1_id: player3.id, player2_id: player4.id, table_number: 30 }
      expect(match_service.update_match(match1.id, match_params)).to be_instance_of(Match)
    end

    it "throws error when match not found" do
      match_params = { start_time: "2400-01-20T17:00:00.000Z", end_time: "2400-01-20T18:00:00.000Z", player1_id: player1.id, player2_id: player2.id, table_number: 10 }
      expect { match_service.update_match(0, match_params) }.to raise_error(HttpErrors::NotFoundError)
    end

    it "throws error when table_number is already occupied" do
      match_params = { start_time: "2500-01-20T17:00:00.000Z", end_time: "2500-01-20T18:00:00.000Z", player1_id: player3.id, player2_id: player4.id, table_number: 10 }
      expect { match_service.update_match(match1.id, match_params) }.to raise_error(HttpErrors::ConflictError)
    end

    it "throws error when player1 is not available" do
      match_params = { start_time: "2500-01-20T17:00:00.000Z", end_time: "2500-01-20T18:00:00.000Z", player1_id: player1.id, player2_id: player3.id, table_number: 20 }
      expect { match_service.update_match(match1.id, match_params) }.to raise_error(HttpErrors::ConflictError)
    end

    it "throws error when player2 is not available" do
      match_params = { start_time: "2500-01-20T17:00:00.000Z", end_time: "2500-01-20T18:00:00.000Z", player1_id: player3.id, player2_id: player2.id, table_number: 20 }
      expect { match_service.update_match(match1.id, match_params) }.to raise_error(HttpErrors::ConflictError)
    end

    it "throws error when start_time is later than end_time" do
      match_params = { start_time: "2500-01-20T18:00:00.000Z", end_time: "2500-01-20T17:00:00.000Z", player1_id: player3.id, player2_id: player4.id, table_number: 20 }
      expect { match_service.update_match(match1.id, match_params) }.to raise_error(HttpErrors::ConflictError)
    end

    it "throws error when start_time is equal to end_time" do
      match_params = { start_time: "2500-01-20T18:00:00.000Z", end_time: "2500-01-20T18:00:00.000Z", player1_id: player3.id, player2_id: player4.id, table_number: 20 }
      expect { match_service.update_match(match1.id, match_params) }.to raise_error(HttpErrors::ConflictError)
    end
  end

  describe "#delete_match" do
    it "deletes the match successfully" do
      expect(match_service.delete_match(match3.id)).to eq(match3)
    end

    it "throws error when match not found" do
      expect { match_service.delete_match(0) }.to raise_error(HttpErrors::NotFoundError)
    end

    it "throws error when match is already started" do
      expect { match_service.delete_match(match1.id) }.to raise_error(HttpErrors::InternalServerError)
    end
  end
end
