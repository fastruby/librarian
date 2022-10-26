class LinksController < ApplicationController
  before_action :set_link, only: %i[ show edit update destroy ]

  # GET /links
  def index
    scope = if params[:domain].present?
      Link.where("url ILIKE ?", "%#{params[:domain]}%")
    else
      Link
    end
    @links = scope.all
  end

  # GET /links/1
  def show
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
end
