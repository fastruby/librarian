class ApplicationController < ActionController::Base
  skip_forgery_protection if: :bearer_token_present?

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
    if request.format.json?
      authenticate_with_personal_access_token!
    else
      authenticate_user!
    end
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

  def bearer_token_present?
    bearer_token.present?
  end
end
