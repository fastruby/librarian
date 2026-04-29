class PersonalAccessTokensController < ApplicationController
  def index
    @personal_access_tokens = current_user.personal_access_tokens.order(created_at: :desc)
    @new_token = PersonalAccessToken.new
  end

  def create
    @new_token = current_user.personal_access_tokens.build(token_params)

    if @new_token.save
      @personal_access_tokens = current_user.personal_access_tokens.order(created_at: :desc)
      @raw_token = @new_token.token
      flash.now[:notice] = "Token created. Copy it now — it won't be shown again."
      render :index, status: :created
    else
      @personal_access_tokens = current_user.personal_access_tokens.order(created_at: :desc)
      render :index, status: :unprocessable_entity
    end
  end

  def destroy
    token = current_user.personal_access_tokens.find(params[:id])
    token.destroy
    redirect_to personal_access_tokens_path, notice: "Token revoked."
  end

  private

  def token_params
    params.require(:personal_access_token).permit(:name)
  end
end
