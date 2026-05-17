require 'rails_helper'

RSpec.describe 'JSON API for links and shares', type: :request do
  before do
    allow_any_instance_of(Link).to receive(:fetch_social_media_snippets).and_return([])
  end

  let(:user) { FactoryBot.create(:user) }
  let(:token) { FactoryBot.create(:personal_access_token, user: user) }
  let(:auth_headers) { { 'Authorization' => "Bearer #{token.token}", 'Accept' => 'application/json' } }

  let!(:fastruby_link) do
    FactoryBot.create(:link,
      url: 'https://www.fastruby.io/blog/some-post.html',
      title: 'FastRuby Post')
  end

  let!(:other_link) do
    FactoryBot.create(:link,
      url: 'https://www.ombulabs.com/blog/another-post.html',
      title: 'OmbuLabs Post')
  end

  describe 'GET /links.json' do
    it 'returns all links for a valid token' do
      get '/links.json', headers: auth_headers

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body.map { |l| l['title'] }).to contain_exactly('FastRuby Post', 'OmbuLabs Post')
    end

    it 'filters by domain' do
      get '/links.json', params: { domain: 'fastruby.io' }, headers: auth_headers

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body.map { |l| l['title'] }).to eq(['FastRuby Post'])
    end

    it 'returns 401 with no token' do
      get '/links.json', headers: { 'Accept' => 'application/json' }
      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns 401 with an invalid token' do
      get '/links.json', headers: { 'Authorization' => 'Bearer wrong', 'Accept' => 'application/json' }
      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns 401 with an expired token' do
      expired = FactoryBot.create(:personal_access_token, user: user, expires_at: 1.hour.ago)
      headers = { 'Authorization' => "Bearer #{expired.token}", 'Accept' => 'application/json' }
      get '/links.json', headers: headers
      expect(response).to have_http_status(:unauthorized)
    end

    it 'accepts a lowercase bearer scheme' do
      headers = { 'Authorization' => "bearer #{token.token}", 'Accept' => 'application/json' }
      get '/links.json', headers: headers
      expect(response).to have_http_status(:ok)
    end

    it 'returns 401 for cookie-authenticated browsers without a Bearer token' do
      sign_in user
      get '/links.json', headers: { 'Accept' => 'application/json' }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /links/:id.json' do
    before do
      fastruby_link.social_media_snippets.create!(content: 'Tweet 1', social_media_type: 'Twitter')
      fastruby_link.social_media_snippets.create!(content: 'LI 1',    social_media_type: 'LinkedIn')
      fastruby_link.shares.create!(
        utm_source: 'LinkedIn', utm_medium: 'Organic',
        utm_campaign: 'Blogpromo', utm_term: 'termOne'
      )
    end

    it 'returns the link with its social_media_snippets and no shares' do
      get "/links/#{fastruby_link.id}.json", headers: auth_headers

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['id']).to eq(fastruby_link.id)
      expect(body['title']).to eq('FastRuby Post')
      expect(body['social_media_snippets'].size).to eq(2)
      expect(body).not_to have_key('shares')
    end

    it 'returns 401 with no token' do
      get "/links/#{fastruby_link.id}.json", headers: { 'Accept' => 'application/json' }
      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns 401 with an invalid token' do
      headers = { 'Authorization' => 'Bearer wrong', 'Accept' => 'application/json' }
      get "/links/#{fastruby_link.id}.json", headers: headers
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /links/:link_id/shares.json' do
    let!(:share) do
      fastruby_link.shares.create!(
        utm_source: 'LinkedIn', utm_medium: 'Organic',
        utm_campaign: 'Blogpromo', utm_term: 'termOne'
      )
    end

    it 'returns the shares for the link' do
      get "/links/#{fastruby_link.id}/shares.json", headers: auth_headers

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body.size).to eq(1)
      expect(body.first['utm_source']).to eq('LinkedIn')
      expect(body.first['link_id']).to eq(fastruby_link.id)
    end

    it 'returns 401 without a token' do
      get "/links/#{fastruby_link.id}/shares.json", headers: { 'Accept' => 'application/json' }
      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns 401 with an invalid token' do
      headers = { 'Authorization' => 'Bearer wrong', 'Accept' => 'application/json' }
      get "/links/#{fastruby_link.id}/shares.json", headers: headers
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'POST /links/:link_id/shares.json' do
    before do
      allow_any_instance_of(Share).to receive(:shorten).and_return('short.link/abc')
    end

    let(:valid_params) do
      {
        share: {
          utm_source: 'LinkedIn',
          utm_medium: 'Organic',
          utm_campaign: 'Blogpromo',
          utm_term: 'termOne',
          utm_content: 'Photo'
        }
      }
    end

    it 'creates a share for a valid token' do
      expect {
        post "/links/#{fastruby_link.id}/shares.json", params: valid_params, headers: auth_headers
      }.to change(Share, :count).by(1)

      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body['utm_source']).to eq('LinkedIn')
      expect(body['link_id']).to eq(fastruby_link.id)
      expect(body['shortened_url']).to eq('https://short.link/abc')
    end

    it 'returns 422 with errors when params are invalid' do
      expect {
        post "/links/#{fastruby_link.id}/shares.json",
          params: { share: { utm_source: '' } },
          headers: auth_headers
      }.not_to change(Share, :count)

      expect(response).to have_http_status(:unprocessable_entity)
      body = JSON.parse(response.body)
      expect(body['errors']).to be_an(Array).and(be_present)
    end

    it 'returns 401 without a token' do
      expect {
        post "/links/#{fastruby_link.id}/shares.json",
          params: valid_params,
          headers: { 'Accept' => 'application/json' }
      }.not_to change(Share, :count)

      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns 401 with an invalid token' do
      headers = { 'Authorization' => 'Bearer wrong', 'Accept' => 'application/json' }
      expect {
        post "/links/#{fastruby_link.id}/shares.json", params: valid_params, headers: headers
      }.not_to change(Share, :count)

      expect(response).to have_http_status(:unauthorized)
    end

    it 'persists the share even if shortening fails' do
      allow_any_instance_of(Share).to receive(:shorten).and_raise(StandardError, 'rebrandly down')

      expect {
        post "/links/#{fastruby_link.id}/shares.json", params: valid_params, headers: auth_headers
      }.to change(Share, :count).by(1)

      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body['shortened_url']).to be_nil
    end
  end

  describe 'Bearer cannot reach write endpoints' do
    it 'cannot create a personal access token' do
      auth_headers # materialize the lazy `token` let so it doesn't pollute the count check
      expect {
        post '/personal_access_tokens.json',
          params: { personal_access_token: { name: 'evil' } },
          headers: auth_headers
      }.not_to change(PersonalAccessToken, :count)
    end

    it 'cannot destroy a personal access token' do
      victim = FactoryBot.create(:personal_access_token, user: user, name: 'victim')
      expect {
        delete "/personal_access_tokens/#{victim.id}.json", headers: auth_headers
      }.not_to change { PersonalAccessToken.exists?(victim.id) }.from(true)
    end

    it 'cannot trigger execute_read_task' do
      # If Bearer reached the action, the controller would shell out via `system('rake read')`.
      # Stub it so a regression here doesn't actually run rake; assert it was never invoked.
      expect_any_instance_of(ApplicationController).not_to receive(:system)
      post '/execute_read_task.json', headers: auth_headers
    end
  end

  describe 'last_used_at' do
    it 'is updated after a successful authenticated request' do
      expect(token.last_used_at).to be_nil
      get '/links.json', headers: auth_headers
      expect(token.reload.last_used_at).to be_present
    end

    it 'is not rewritten on every request within the debounce window' do
      get '/links.json', headers: auth_headers
      first_seen = token.reload.last_used_at
      expect(first_seen).to be_present

      get '/links.json', headers: auth_headers
      expect(token.reload.last_used_at).to be_within(0.001.seconds).of(first_seen)
    end

    it 'is rewritten once the debounce window has passed' do
      get '/links.json', headers: auth_headers
      first_seen = token.reload.last_used_at

      travel_to(2.minutes.from_now) do
        get '/links.json', headers: auth_headers
      end
      expect(token.reload.last_used_at).to be > first_seen
    end
  end
end
