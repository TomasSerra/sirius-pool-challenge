class PlayerSerializer < ActiveModel::Serializer
  attributes :id, :name, :profile_picture_url, :ranking, :preferred_cue, :created_at, :updated_at, :wins
end
