class PostsController < ApplicationController

  before_action :require_login

  def index
    #@posts=Post.all.order("created_at DESC")
    @posts=Post.all.where(email: [current_user.email])
  end

  def new
    @post=Post.new
  end


  def create

    parametros=post_params
    parametros[:email]=current_user.email

    @post=Post.new(parametros)

    if @post.save
      redirect_to @post
    else
      render 'new'
    end
  end

  def show
    #@post= Post.find(params[:id])
    url=Post.find(params[:id])

    if url[:email]==current_user.email then
      puts "entre aqui"
      @post=url
    else
      render 'index'
    end
  end

  private

  def post_params
      params.require(:post).permit(:title, :content, :email )
  end
end
