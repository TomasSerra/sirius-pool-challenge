class UpdatePlayerRankingsJob < ApplicationJob
  queue_as :default

  def perform
    players = Player.order(wins: :desc)

    players.each_with_index do |player, index|
      player.update(ranking: index + 1)
    end
  end
end
