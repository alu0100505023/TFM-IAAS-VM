class PostsController < ApplicationController

  before_action :require_login


  def index
    #@posts=Post.all.order("created_at DESC")
    @posts = Post.all.where(email: [current_user.email])
    @vm = Services::Ansible.new()
    @vm.format_variable_yml
    Services::MachinesController.new().new_ip
  end

  def new
    @post=Post.new
  end


  def createVM
    @vm = Services::Ansible.new()
    @response = @vm.basicVM()

    puts "Respuesta del controlador: " + @response
    render json: @response
  end

  def create
    pool_params = params[:pool]
    machines_params = params[:machine]
    params = post_params
    params[:email] = current_user.email

    Rails.logger.info params[:pool]
    @post=Post.new(params)

    if @post.save
      pool = create_pool(pool_params)
      if @pool.save
        create_machines(machines_params, "simple", @pool)
        redirect_to @post
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

    @pool = Pool.find_by(:post => url)
    @machines = Machine.where(:pool => @pool)

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
                     :masters => 1, :slaves => pool_params["slaves"], :post=> @post)
  end

  def create_machines(machines_params, machines_type, pool)
    @machine_service = Services::MachinesController.new
    @machine_service.create_machine_pool(machines_params, machines_type, pool)
  end

  def post_params
      params.require(:post).permit(:title, :content, :email )
  end
end
