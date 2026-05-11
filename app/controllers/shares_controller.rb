class SharesController < ApplicationController
  before_action :find_link
  before_action :set_share, only: %i[ show edit clone update destroy ]

  # GET /shares
  def index
    @shares = @link.shares

    respond_to do |format|
      format.html
      format.json { render json: @shares.map { |s| share_json(s) } }
    end
  end

  # GET /shares/1
  def show
  end

  # GET /shares/new
  def new
    @share = @link.shares.build
  end

  # GET /shares/1/clone
  def clone
    @cloned_share = @share.dup
    render :new, locals: { share: @cloned_share }
  end

  # POST /shares
  def create
    @share = @link.shares.build(share_params)

    if @share.save
      @share.update shortened_url: "https://#{@share.shorten}"
      redirect_to @link, notice: "Share was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

    def find_link
      @link = Link.find(params[:link_id])
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_share
      @share = @link.shares.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def share_params
      params.require(:share).permit(:link_id, :shortened_url, :utm_source, :utm_medium, :utm_campaign, :utm_term, :utm_content, :utm_id, :shared_link_name)
    end

    def share_json(share)
      {
        id: share.id,
        link_id: share.link_id,
        shortened_url: share.shortened_url,
        utm_source: share.utm_source,
        utm_medium: share.utm_medium,
        utm_campaign: share.utm_campaign,
        utm_term: share.utm_term,
        utm_content: share.utm_content,
        utm_id: share.utm_id,
        shared_link_name: share.shared_link_name,
        created_at: share.created_at,
        updated_at: share.updated_at
      }
    end
end
