class UsersController < ApplicationController
  skip_before_action :authorize, only: [:new, :create]

  def index
    @users = User.page(params[:page])
  end

  def show
    @user = User.find(params[:id])
    @followed_users = current_user.followed_users.limit(5)
    @followers = current_user.followers.limit(5)
  end

  def new
    @user = User.new
    @user.apply_oauth(session[:omniauth]) if session[:omniauth]
  end

  def edit
    @user = current_user
  end

  def create
    @user = User.new(user_params)
    @user.icon_image = gravatar_url(@user)
    @user.apply_oauth(session[:omniauth]) if session[:omniauth]
    session[:omniauth] = nil if @user.persisted?
    if @user.save
      session[:user_id] = @user.id
      flash[:success] = '登録完了しました。'
      redirect_to :root
    else
      render action: 'new'
    end
  end

  def update
    @user = current_user
    @user.assign_attributes(user_params)
    if @user.save
      flash[:success] = '設定を更新しました。'
      redirect_to :root
    else
      render action: 'edit'
    end
  end

  def destroy
    current_user.destroy
    flash[:success] = 'アカウントを削除しました。'
    redirect_to :root
  end

  def following
    @title = 'フォロー'
    @user = User.find(params[:id])
    @users = @user.followed_users.page(params[:page])
    render 'show_follow'
  end

  def followers
    @title = 'フォロワー'
    @user = User.find(params[:id])
    @users = @user.followers.page(params[:page])
    render 'show_follow'
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password,
      :password_confirmation, :icon_image)
  end
end
