class Editor::Base < Base
  before_action :check_timeout
  before_action :require_editor_user

  private
  def require_editor_user
    if current_user && !current_user.editor?
      flash[:warning] = '編集者としてログインしてください。'
      redirect_to :root
    end
  end

  TIMEOUT = 30.minutes

  def check_timeout
    if current_user
      if session[:last_access_time] >= TIMEOUT.ago
        session[:last_access_time] = Time.current
      else
        cookies.delete(:remember_token)
        flash[:warning] = 'セッションがタイムアウトしました。'
        redirect_to :editor_login
      end
    end
  end
end
