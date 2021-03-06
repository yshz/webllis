class RepliesController < ApplicationController
  before_action :fetch_post
  before_action :fetch_comment

  def new
    @reply = Comment.new
  end

  # POST
  def confirm
    @reply = Comment.new(comment_params)
    if @reply.valid?
      render action: 'confirm'
    else
      flash.now[:danger] = '入力に誤りがあります。'
      render action: 'new'
    end
  end

  def create
    @reply = Comment.new(comment_params)
    @reply.creator = current_user
    @reply.post = @post
    @reply.parent = @comment
    if params[:commit] && @reply.save
      flash[:success] = 'コメントに返信しました。'
      redirect_to @post
    else
      flash.now[:danger] = '入力に誤りがあります。'
      render action: 'new'
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:content)
  end
end
