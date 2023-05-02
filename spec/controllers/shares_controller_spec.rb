require 'rails_helper'

describe SharesController, type: :controller do
  let(:text) do
    ['1) Avoid these common mistakes when upgrading your #Rails application! Learn more in our latest blog post: https://www.fastruby.io/blog/rails/upgrades/7-common-mistakes-made-while-doing-rails-upgrades.html #webdevelopment #rubyonrails',
     '2) Are you planning to upgrade your #Rails app? Make sure to read our latest blog post to avoid these 7 common mistakes: https://www.fastruby.io/blog/rails/upgrades/7-common-mistakes-made-while-doing-rails-upgrades.html #webdev #upgradesuccess',
     "3) Upgrading your #Rails app can be tricky, but it doesn't have to be! Check out our latest blog post to learn about common mistakes to avoid: https://www.fastruby.io/blog/rails/upgrades/7-common-mistakes-made-while-doing-rails-upgrades.html #rubyonrails #webdevelopment"]
  end

  before do
    allow(subject).to receive(:http_basic_authenticate_or_request_with)
      .with(anything).and_return true

    allow_any_instance_of(Link).to(
      receive(:fetch_social_media_snippets).and_return(text)
    )
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
