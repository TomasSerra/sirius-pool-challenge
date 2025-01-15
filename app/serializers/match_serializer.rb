class MatchSerializer < ActiveModel::Serializer
  attributes :id, :player1_id, :player2_id, :start_time, :end_time, :winner_id, :table_number
end
