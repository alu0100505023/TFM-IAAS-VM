class PostsController < ApplicationController

  before_action :require_login
  @project_type = "simple"
  @current_post, @current_pool = nil

  def index
    #@posts=Post.all.order("created_at DESC")
    Rails.logger.info ANSIBLE_CONFIG
    @posts = Post.all.where(email: [current_user.email])
    @vm = Services::Ansible.new()
    @vm.format_variable_yml
    @vm.create_user_directory(current_user.email)
  end

  def new
    @@project_type = "simple"
    @post = Post.new
  end

  def get_output
    @vm = Services::Ansible.new()
    @response = @vm.get_output(@@current_post.email, @@current_pool)
    render json: @response
  end

  def createVM
    @vm = Services::Ansible.new()
    @response = @vm.basicVM()
    puts "Respuesta del controlador: " + @response
    render json: @response
  end

  def create
    @vm = Services::Ansible.new()
    @ck = Services::Cookbooks.new()
    pool_params = params[:pool]
    pool_params[:pool_type] = @@project_type
    machines_params = params[:machine]
    params = post_params
    params[:email] = current_user.email

    Rails.logger.info params[:pool]

    @post = Post.new(params)

    if @post.save
      pool = create_pool(pool_params)
      if @pool.save
        create_machines(machines_params, @@project_type, @pool)
        @machines = Machine.where(:pool => @pool)
        @vm.create_pool_directory(current_user.email, @pool)
        @vm.ansible_variable_yml(current_user.email, @pool, @machines)

        redirect_to @post

        @vm.run_create_machines(current_user.email, @pool)
      else
        render 'new'
      end
    else
      render 'new'
    end
  end

  def new_cluster
    @@project_type = "cluster"
    @post = Post.new
  end

  def create_cluster
    @vm = Services::Ansible.new()
    pool_params = params[:pool]
    machines_params = params[:machine]
    params = post_params
    params[:email] = current_user.email

    Rails.logger.info params[:pool]
    @post = Post.new(params)

    if @post.save
      pool = create_pool(pool_params)
      if @pool.save
        create_machines(machines_params, "simple", @pool)
        @machines = Machine.where(:pool => @pool)
        @vm.create_pool_directory(current_user.email, @pool)
        @vm.ansible_variable_yml(@pool, @machines)
        redirect_to @post
        @vm.run_create_machines(current_user.email, @pool)
      else
        render 'new'
      end
    else
      render 'new'
    end
  end

  def show
    #@post= Post.find(params[:id])
    url = Post.find(params[:id])
    @vm = Services::Ansible.new()
    @pool = Pool.find_by(:post => url)
    @machines = Machine.where(:pool => @pool)
    @vm.get_external_ip(current_user.email, @pool, @machines)

    @@current_post = url
    @@current_pool = @pool
    if url[:email] == current_user.email then
      @post = url
    else
      render 'index'
    end
  end

  private

  def create_pool(pool_params)
    Rails.logger.info pool_params
    @pool = Pool.new(:storage_domain => pool_params["storage_domain"], :cluster => pool_params[:cluster], :template => pool_params[:template], :instance_type => "xl",
                     :masters => 1, :slaves => pool_params["slaves"], :pool_type => pool_params[:pool_type], :post=> @post)
  end

  def create_machines(machines_params, machines_type, pool)
    @machine_service = Services::MachinesController.new
    @machine_service.create_machine_pool(machines_params, machines_type, pool)
  end

  def post_params
      params.require(:post).permit(:title, :content, :email )
  end
end
