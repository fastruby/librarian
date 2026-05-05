require "digest"
require "securerandom"

class PersonalAccessToken < ApplicationRecord
  TOKEN_PREFIX = "lib_".freeze

  belongs_to :user

  validates :name, presence: true
  validates :token_digest, presence: true, uniqueness: true

  attr_reader :token

  before_validation :assign_token, on: :create

  def self.authenticate(raw_token)
    return nil if raw_token.blank?
    pat = find_by(token_digest: digest_for(raw_token))
    return nil if pat && pat.expires_at && pat.expires_at <= Time.current
    pat
  end

  def self.digest_for(raw_token)
    Digest::SHA256.hexdigest(raw_token)
  end

  private

  def assign_token
    return if token_digest.present?
    @token = "#{TOKEN_PREFIX}#{SecureRandom.hex(32)}"
    self.token_digest = self.class.digest_for(@token)
  end
end
