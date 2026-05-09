class ApplicationController < ActionController::Base
  # (controller_name, action_name) pairs that accept Bearer-token auth.
  # Anything not listed here goes through Devise even when JSON is requested,
  # so a PAT cannot reach write endpoints via content negotiation.
  API_ENDPOINTS = {
    "links"  => %w[index show],
    "shares" => %w[index]
  }.freeze

  skip_forgery_protection if: :api_endpoint?

  before_action :authenticate_request!

  def execute_read_task
    system('rake read')
    flash[:notice] = "Read task executed!"
    redirect_back_or_to root_path
  end

  def current_user
    @current_user || super
  end

  private

  def authenticate_request!
    if api_endpoint?
      authenticate_with_personal_access_token!
    else
      authenticate_user!
    end
  end

  def api_endpoint?
    request.format.json? &&
      API_ENDPOINTS[controller_name]&.include?(action_name)
  end

  def authenticate_with_personal_access_token!
    pat = PersonalAccessToken.authenticate(bearer_token)

    if pat
      touch_last_used_at(pat)
      @current_user = pat.user
    else
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end

  def touch_last_used_at(pat)
    return if pat.last_used_at && pat.last_used_at > 1.minute.ago
    pat.update_column(:last_used_at, Time.current)
  end

  def bearer_token
    request.authorization.to_s[/\ABearer\s+(.+)\z/i, 1]&.strip
  end
end
