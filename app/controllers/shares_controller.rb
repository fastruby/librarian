class SharesController < ApplicationController
  before_action :find_link
  before_action :set_share, only: %i[ show edit update destroy ]

  # GET /shares
  def index
    @shares = @link.shares
  end

  # GET /shares/1
  def show
  end

  # GET /shares/new
  def new
    @share = @link.shares.build
  end

  # GET /shares/1/edit
  def edit
  end

  # POST /shares
  def create
    @share = @link.shares.build(share_params)

    if @share.save
      redirect_to @link, notice: "Share was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /shares/1
  def update
    if @share.update(share_params)
      redirect_to @share, notice: "Share was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /shares/1
  def destroy
    @share.destroy
    redirect_to shares_url, notice: "Share was successfully destroyed."
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
end
