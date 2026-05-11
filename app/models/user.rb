class User < ApplicationRecord
  include OmbuLabsAuthenticable

  has_many :personal_access_tokens, dependent: :destroy
end