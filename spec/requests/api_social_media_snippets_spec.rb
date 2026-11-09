require 'rails_helper'

RSpec.describe 'JSON API for social media snippets', type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:token) { FactoryBot.create(:personal_access_token, user: user) }
  let(:auth_headers) { { 'Authorization' => "Bearer #{token.token}", 'Accept' => 'application/json' } }

  let!(:link) { FactoryBot.create(:link, url: 'https://www.fastruby.io/blog/some-post.html', title: 'Some Post') }
  let!(:other_link) { FactoryBot.create(:link, url: 'https://www.fastruby.io/blog/another-post.html', title: 'Another Post') }

  describe 'GET /links/:link_id/social_media_snippets.json' do
    let!(:linkedin_snippet) { FactoryBot.create(:social_media_snippet, link: link, social_media_type: 'LinkedIn', content: 'On LinkedIn') }
    let!(:mastodon_snippet) { FactoryBot.create(:social_media_snippet, link: link, social_media_type: 'Mastodon', content: 'On Mastodon') }
    let!(:other_snippet) { FactoryBot.create(:social_media_snippet, link: other_link, content: 'Another link') }

    it "returns only the link's snippets" do
      get "/links/#{link.id}/social_media_snippets.json", headers: auth_headers

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body.map { |s| s['content'] }).to eq(['On LinkedIn', 'On Mastodon'])
      expect(body.first.keys).to match_array(%w[id link_id social_media_type content share_id created_at])
    end

    it 'filters by social_media_type' do
      get "/links/#{link.id}/social_media_snippets.json",
        params: { social_media_type: 'Mastodon' }, headers: auth_headers

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).map { |s| s['content'] }).to eq(['On Mastodon'])
    end

    it 'returns an empty list for a link with no snippets' do
      empty_link = FactoryBot.create(:link, url: 'https://www.fastruby.io/blog/empty.html')
      get "/links/#{empty_link.id}/social_media_snippets.json", headers: auth_headers

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq([])
    end

    it 'raises RecordNotFound for an unknown link (Rails answers 404 outside the test environment)' do
      expect {
        get '/links/0/social_media_snippets.json', headers: auth_headers
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'returns 401 without a token' do
      get "/links/#{link.id}/social_media_snippets.json", headers: { 'Accept' => 'application/json' }
      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns 401 with an invalid token' do
      headers = { 'Authorization' => 'Bearer wrong', 'Accept' => 'application/json' }
      get "/links/#{link.id}/social_media_snippets.json", headers: headers
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'POST /links/:link_id/social_media_snippets.json' do
    let(:valid_params) do
      { social_media_snippet: { social_media_type: 'LinkedIn', content: 'A fresh take on the post.' } }
    end

    def post_snippet(params, headers: auth_headers, to: link)
      post "/links/#{to.id}/social_media_snippets.json", params: params, headers: headers
    end

    it 'creates a snippet for a valid token' do
      expect { post_snippet(valid_params) }.to change(SocialMediaSnippet, :count).by(1)

      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body['link_id']).to eq(link.id)
      expect(body['social_media_type']).to eq('LinkedIn')
      expect(body['content']).to eq('A fresh take on the post.')
      expect(body['share_id']).to be_nil
      expect(body['id']).to be_present
      expect(body['created_at']).to be_present
    end

    it 'accepts every supported social media type' do
      SocialMediaSnippet::SOCIAL_MEDIA_TYPES.each do |type|
        post_snippet({ social_media_snippet: { social_media_type: type, content: "Copy for #{type}" } })
        expect(response).to have_http_status(:created), "expected #{type} to be accepted"
      end
    end

    it 'shows up in GET /links/:id.json' do
      post_snippet(valid_params)

      get "/links/#{link.id}.json", headers: auth_headers
      contents = JSON.parse(response.body)['social_media_snippets'].map { |s| s['content'] }
      expect(contents).to eq(['A fresh take on the post.'])
    end

    context 'with a share_id' do
      let!(:share) { FactoryBot.create(:share, link: link) }

      it 'ties the snippet to the share' do
        post_snippet({ social_media_snippet: valid_params[:social_media_snippet].merge(share_id: share.id) })

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['share_id']).to eq(share.id)
        expect(SocialMediaSnippet.last.share).to eq(share)
      end

      it 'returns 422 when the share belongs to another link' do
        other_share = FactoryBot.create(:share, link: other_link)

        expect {
          post_snippet({ social_media_snippet: valid_params[:social_media_snippet].merge(share_id: other_share.id) })
        }.not_to change(SocialMediaSnippet, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to include('Share must belong to the same link')
      end

      it 'returns 422, not a server error, when the share does not exist' do
        expect {
          post_snippet({ social_media_snippet: valid_params[:social_media_snippet].merge(share_id: 0) })
        }.not_to change(SocialMediaSnippet, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to include('Share must exist')
      end
    end

    it 'returns 422 when content is missing' do
      expect {
        post_snippet({ social_media_snippet: { social_media_type: 'LinkedIn', content: '' } })
      }.not_to change(SocialMediaSnippet, :count)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['errors']).to include("Content can't be blank")
    end

    it 'returns 422 for an unknown social media type' do
      expect {
        post_snippet({ social_media_snippet: { social_media_type: 'Myspace', content: 'Hello' } })
      }.not_to change(SocialMediaSnippet, :count)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['errors']).to include('Social media type is not included in the list')
    end

    it 'returns 422 when the social media type is missing' do
      post_snippet({ social_media_snippet: { content: 'Hello' } })

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['errors']).to include("Social media type can't be blank")
    end

    it 'returns 422 for an exact duplicate, so a retry is safe' do
      post_snippet(valid_params)

      expect { post_snippet(valid_params) }.not_to change(SocialMediaSnippet, :count)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['errors'].first).to match(/has already been saved/)
    end

    it 'accepts the same content on another network or another link' do
      post_snippet(valid_params)

      post_snippet({ social_media_snippet: valid_params[:social_media_snippet].merge(social_media_type: 'Mastodon') })
      expect(response).to have_http_status(:created)

      post_snippet(valid_params, to: other_link)
      expect(response).to have_http_status(:created)
    end

    it 'accepts a JSON body, with or without the social_media_snippet wrapper' do
      headers = auth_headers.merge('Content-Type' => 'application/json')

      post "/links/#{link.id}/social_media_snippets.json",
        params: { social_media_type: 'Bluesky', content: 'Flat JSON body' }.to_json, headers: headers
      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)['content']).to eq('Flat JSON body')

      post "/links/#{link.id}/social_media_snippets.json",
        params: { social_media_snippet: { social_media_type: 'Mastodon', content: 'Wrapped JSON body' } }.to_json,
        headers: headers
      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)['content']).to eq('Wrapped JSON body')
    end

    it 'raises ParameterMissing without any snippet params (Rails answers 400 outside the test environment)' do
      expect { post_snippet({}) }.to raise_error(ActionController::ParameterMissing)
    end

    it 'raises RecordNotFound for an unknown link and creates nothing' do
      expect {
        expect {
          post '/links/0/social_media_snippets.json', params: valid_params, headers: auth_headers
        }.to raise_error(ActiveRecord::RecordNotFound)
      }.not_to change(SocialMediaSnippet, :count)
    end

    it 'returns 401 without a token' do
      expect {
        post_snippet(valid_params, headers: { 'Accept' => 'application/json' })
      }.not_to change(SocialMediaSnippet, :count)

      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns 401 with an invalid token' do
      headers = { 'Authorization' => 'Bearer wrong', 'Accept' => 'application/json' }

      expect { post_snippet(valid_params, headers: headers) }.not_to change(SocialMediaSnippet, :count)
      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns 401 for cookie-authenticated browsers without a Bearer token' do
      sign_in user

      expect {
        post_snippet(valid_params, headers: { 'Accept' => 'application/json' })
      }.not_to change(SocialMediaSnippet, :count)

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
