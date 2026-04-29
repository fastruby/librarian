class ApplicationController < ActionController::Base
  skip_forgery_protection if: -> { request.format.json? }

  before_action :authenticate_request!

  def execute_read_task
    system('rake read')
    flash[:notice] = "Read task executed!"
    redirect_back_or_to root_path
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
    raw_token = bearer_token
    pat = PersonalAccessToken.authenticate(raw_token)

    if pat
      pat.update_column(:last_used_at, Time.current)
      sign_in pat.user, store: false
    else
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end

  def bearer_token
    header = request.headers["Authorization"].to_s
    header.start_with?("Bearer ") ? header.split(" ", 2).last : nil
  end
end
