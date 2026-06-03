require 'rails_helper'

describe SharesController, type: :controller do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    user = FactoryBot.create(:user)
    sign_in user
  end

  describe 'GET #clone' do
    it 'should create a clone' do
      share = FactoryBot.create(:share)
      get :clone, params: { id: share.id, link_id: share.link.id }
      expect(response).to render_template :new
      expect(assigns(:cloned_share).utm_source).to eq share.utm_source
    end

    it 'should increase the share count by 1' do
      expect do
        share = FactoryBot.create(:share)
        get :clone, params: { id: share.id, link_id: share.link.id }
      end.to change(Share, :count).by(1)
    end
  end
end
