class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  def execute_read_task
    system('rake read')
    flash[:notice] = "Read task executed!"
    redirect_back_or_to root_path
  end
end
