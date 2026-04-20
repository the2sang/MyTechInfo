class PostsController < ApplicationController
  allow_unauthenticated_access only: %i[ index show ]
  before_action :set_post, only: %i[ show edit update destroy ]
  before_action :authorize_post!, only: %i[ edit update destroy ]

  def index
    @posts = Post.includes(:user).recent
  end

  def show
  end

  def new
    @post = Post.new
  end

  def edit
  end

  def create
    @post = Current.session.user.posts.build(post_params)

    if @post.save
      redirect_to @post, notice: "Post was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @post.update(post_params)
      redirect_to @post, notice: "Post was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @post.destroy!
    redirect_to posts_path, notice: "Post was successfully deleted.", status: :see_other
  end

  private

  def set_post
    @post = Post.find(params.expect(:id))
  end

  def post_params
    params.expect(post: [ :title ])
  end

  def authorize_post!
    redirect_to root_path, alert: "Not authorized." unless @post.user == Current.session.user
  end
end
