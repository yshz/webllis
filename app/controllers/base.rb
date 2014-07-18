class Base < ApplicationController
  before_action :authorize
  before_action :check_account

  private
  def login(user)
    remember_token = User.new_remember_token
    cookies.permanent[:remember_token] = remember_token
    user.update_attribute(:remember_token, User.encrypt(remember_token))
    self.current_user = user
  end

  def current_user=(user)
    @current_user = user
  end

  def current_user
    remember_token = User.encrypt(cookies[:remember_token])
    @current_user ||= User.find_by(remember_token: remember_token)
  end

  helper_method :current_user

  def current_user?(user)
    user == current_user
  end

  helper_method :current_user?

  def logged_in?
    !current_user.nil?
  end

  helper_method :logged_in?

  def logout
    self.current_user = nil
    cookies.delete(:remember_token)
  end

  def authorize
    unless current_user
      store_location
      flash[:warning] = 'ログインしてください。'
      redirect_to :login
    end
  end

  def redirect_back_or(default)
    redirect_to(session[:return_to] || default)
    session.delete(:return_to)
  end

  def store_location
    session[:return_to] = request.url
  end

  def check_account
    if current_user && !current_user.active?
      cookies.delete(:remember_token)
      flash[:warning] = 'アカウントが無効になりました。'
      redirect_to :root
    end
  end

  def search_form
    SearchForm.new(params[:search])
  end

  helper_method :search_form
end
