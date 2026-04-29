require 'rails_helper'

RSpec.describe PersonalAccessToken, type: :model do
  describe '#token' do
    it 'is generated on create and exposed via attr_reader' do
      pat = FactoryBot.create(:personal_access_token)
      expect(pat.token).to be_present
      expect(pat.token.length).to eq(64)
    end

    it 'is stored hashed, not plaintext' do
      pat = FactoryBot.create(:personal_access_token)
      expect(pat.token_digest).to eq(Digest::SHA256.hexdigest(pat.token))
      expect(pat.token_digest).not_to eq(pat.token)
    end

    it 'is not retrievable after reload' do
      pat = FactoryBot.create(:personal_access_token)
      reloaded = PersonalAccessToken.find(pat.id)
      expect(reloaded.token).to be_nil
    end
  end

  describe '.authenticate' do
    it 'returns the token record for a valid raw token' do
      pat = FactoryBot.create(:personal_access_token)
      expect(PersonalAccessToken.authenticate(pat.token)).to eq(pat)
    end

    it 'returns nil for an invalid raw token' do
      FactoryBot.create(:personal_access_token)
      expect(PersonalAccessToken.authenticate('not-a-real-token')).to be_nil
    end

    it 'returns nil for a blank token' do
      expect(PersonalAccessToken.authenticate(nil)).to be_nil
      expect(PersonalAccessToken.authenticate('')).to be_nil
    end
  end

  describe 'validations' do
    it 'requires a name' do
      pat = PersonalAccessToken.new(user: FactoryBot.create(:user))
      expect(pat).not_to be_valid
      expect(pat.errors[:name]).to be_present
    end
  end
end
