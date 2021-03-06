class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  layout :set_layout

  before_action :authorize
  before_action :check_account

  helper_method :current_user
  helper_method :current_user?
  helper_method :logged_in?
  helper_method :gravatar_url

  class Forbidden < ActionController::ActionControllerError; end
  class IpAddressRejected < ActionController::ActionControllerError; end

  include ErrorHandlers unless Rails.env.development?
  rescue_from ApplicationController::Forbidden, with: :rescue403
  rescue_from ApplicationController::IpAddressRejected, with: :rescue403

  private

  def set_layout
    if params[:controller].match(%r{\A(editor|admin)/})
      Regexp.last_match[1]
    else
      'application'
    end
  end

  def rescue403(e)
    @exception = e
    render 'errors/forbidden', status: 403
  end

  def reject_non_xhr
    raise ActionController::BadRequest unless request.xhr?
  end

  def authorize
    unless current_user
      store_location
      flash[:warning] = 'ログインしてください。'
      if params[:controller].match(%r{\A(editor)/})
        redirect_to :"#{Regexp.last_match[1]}_login"
      else
        redirect_to :login
      end
    end
  end

  def check_account
    if current_user && !current_user.active?
      current_user.events.create!(type: 'rejected')
      logout
      flash[:warning] = 'アカウントが無効になりました。'
      redirect_to :root
    end
  end

  def current_user
    if user_id = cookies.signed[:user_id] || session[:user_id]
      @current_user ||= User.find_by(id: user_id)
    end
  end

  def current_user?(user)
    user == current_user
  end

  def logged_in?
    !current_user.nil?
  end

  def login(user, object = nil)
    if object.present? && object.remember_me?
      cookies.permanent.signed[:user_id] = user.id
    else
      cookies.delete(:user_id)
      session[:user_id] = user.id
    end
  end

  def redirect_back_or_root_after_login(user)
    user.events.create!(type: 'logged_in')
    flash[:info] = 'ログインしました。'
    redirect_back_or :root
  end

  def logout
    cookies.delete(:user_id)
    session.delete(:user_id)
  end

  def redirect_back_or(default)
    redirect_to(session[:return_to] || default)
    session.delete(:return_to)
  end

  def store_location
    session[:return_to] = request.url
  end

  def gravatar_url(user)
    gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
    "https://secure.gravatar.com/avatar/#{gravatar_id}?s=50"
  end

  def fetch_post
    @post = Post.find(params[:post_id]) if params[:post_id].present?
  end

  def fetch_comment
    id = params[:id] || params[:comment_id]
    @comment = Comment.find(id)
  end
end
