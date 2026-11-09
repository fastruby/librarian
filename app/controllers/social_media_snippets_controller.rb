class SocialMediaSnippetsController < ApplicationController
  before_action :find_link

  # GET /links/1/social_media_snippets.json
  # Optional ?social_media_type=LinkedIn narrows the list to one network.
  def index
    snippets = @link.social_media_snippets.order(:created_at, :id)
    snippets = snippets.where(social_media_type: params[:social_media_type]) if params[:social_media_type].present?

    respond_to do |format|
      format.json { render json: snippets.map { |s| snippet_json(s) } }
    end
  end

  # POST /links/1/social_media_snippets.json
  def create
    @snippet = @link.social_media_snippets.build(snippet_params)

    respond_to do |format|
      format.json do
        if @snippet.save
          render json: snippet_json(@snippet), status: :created
        else
          render json: { errors: @snippet.errors.full_messages }, status: :unprocessable_entity
        end
      end
    end
  end

  private

    def find_link
      @link = Link.find(params[:link_id])
    end

    def snippet_params
      params.require(:social_media_snippet).permit(:social_media_type, :content)
    end

    def snippet_json(snippet)
      {
        id: snippet.id,
        link_id: snippet.link_id,
        social_media_type: snippet.social_media_type,
        content: snippet.content,
        created_at: snippet.created_at
      }
    end
end
