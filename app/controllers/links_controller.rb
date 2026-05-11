class LinksController < ApplicationController
  before_action :set_link, only: %i[ show edit update destroy ]

  # GET /links
  def index
    scope = if params[:domain].present?
      Link.where("url ILIKE ?", "%#{params[:domain]}%")
    else
      Link
    end
    @links = scope.order("published_at DESC NULLS LAST")

    respond_to do |format|
      format.html
      format.json { render json: @links.map { |l| link_json(l) } }
    end
  end

  # GET /links/1
  def show
    @grouped_social_media_snippets = @link.social_media_snippets.group_by(&:social_media_type)

    respond_to do |format|
      format.html
      format.json do
        render json: link_json(@link).merge(
          social_media_snippets: @link.social_media_snippets.map { |s| snippet_json(s) }
        )
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_link
      @link = Link.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def link_params
      params.require(:link).permit(:url, :title, :description)
    end

    def link_json(link)
      {
        id: link.id,
        url: link.url,
        title: link.title,
        description: link.description,
        open_graph_description: link.open_graph_description,
        published_at: link.published_at,
        created_at: link.created_at,
        updated_at: link.updated_at
      }
    end

    def snippet_json(snippet)
      {
        id: snippet.id,
        social_media_type: snippet.social_media_type,
        content: snippet.content,
        created_at: snippet.created_at
      }
    end
end
