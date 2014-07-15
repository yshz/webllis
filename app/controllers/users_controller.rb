class UsersController < Base
  skip_before_action :authorize, only: [:new, :create]

  def index
    @users = User.order(created_at: :desc).page(params[:page])
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def edit
    @user = current_user
  end

  def create
    @user = User.new(user_params)
    if @user.save
      login @user
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

  private
  def user_params
    params.require(:user).permit(:name, :email, :password,
      :password_confirmation)
  end
end
