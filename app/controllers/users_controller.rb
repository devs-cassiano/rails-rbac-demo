class UsersController < ApplicationController
  skip_before_action :verify_authenticity_token
  include RoleAuthorization

  before_action :authenticate_user!, except: [:create]
  before_action :set_user, only: [:show, :update, :destroy, :update_role]
  before_action :authorize_update, only: [:update]
  before_action :authorize_update_role, only: [:update_role]
  before_action :authorize_index, only: [:index]
  before_action :authorize_destroy, only: [:destroy]

  # GET /users
  def index
    @users = User.all
    render json: @users
  end

  # GET /users/:id
  def show
    render json: @user
  end

  # POST /users
  def create
    if current_user.nil?
      # Guest: força role para 'user' e ignora qualquer role enviada
      user_params_guest = params.require(:user).permit(:name, :username, :email, :password)
      @user = User.new(user_params_guest.merge(role: 'user'))
    elsif current_user.role == 'admin'
      @user = User.new(user_params)
    elsif current_user.role == 'manager'
      up = params.require(:user).permit(:name, :username, :email, :password, :role)
      up[:role] = 'user' unless %w[user manager].include?(up[:role])
      @user = User.new(up)
    else
      render json: { error: 'Not Authorized' }, status: :forbidden and return
    end
    if @user.save
      render json: @user, status: :created
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/:id
  def update
    if @user.update(user_params)
      render json: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/:id
  def destroy
    if current_user&.role.in?(['admin', 'manager'])
      @user.destroy
      head :no_content
    else
      render json: { error: 'Not Authorized' }, status: :forbidden
    end
  end

  # PATCH /users/:id/update_role
  def update_role
    # Apenas admin pode atribuir qualquer role
    if current_user&.role == 'admin'
      if @user.update(role_params)
        render json: @user
      else
        render json: @user.errors, status: :unprocessable_entity
      end
    # Manager só pode atribuir 'manager' ou 'user'
    elsif current_user&.role == 'manager'
      if %w[user manager].include?(params[:user][:role])
        if @user.update(role_params)
          render json: @user
        else
          render json: @user.errors, status: :unprocessable_entity
        end
      else
        render json: { error: 'Not Authorized' }, status: :forbidden
      end
    else
      render json: { error: 'Not Authorized' }, status: :forbidden
    end
  end

  private
    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      # Permite alteração de email apenas para admin
      permitted = [:name, :username, :email]
      permitted << :password if params[:user][:password].present?
      permitted << :role if current_user&.role == 'admin' || current_user&.role == 'manager'
      params.require(:user).permit(permitted)
    end

    def role_params
      params.require(:user).permit(:role)
    end

    def authorize_index
      render json: { error: 'Not Authorized' }, status: :forbidden if current_user&.role == 'user'
    end

    def authorize_destroy
      render json: { error: 'Not Authorized' }, status: :forbidden if current_user&.role == 'user'
    end

    def authorize_update
      # Admin e manager podem atualizar qualquer usuário
      return if current_user&.role.in?(['admin', 'manager'])
      # Usuário só pode atualizar seus próprios dados simples
      if current_user == @user
        allowed = params[:user].keys.map(&:to_sym) - [:role, :email]
        unless allowed.all? { |k| %i[name username password].include?(k) }
          render json: { error: 'Not Authorized' }, status: :forbidden
        end
      else
        render json: { error: 'Not Authorized' }, status: :forbidden
      end
    end

    def authorize_update_role
      # Apenas admin pode atribuir qualquer role
      return if current_user&.role == 'admin'
      # Manager só pode atribuir 'manager' ou 'user'
      if current_user&.role == 'manager'
        unless %w[user manager].include?(params[:user][:role])
          render json: { error: 'Not Authorized' }, status: :forbidden
        end
      else
        render json: { error: 'Not Authorized' }, status: :forbidden
      end
    end
end
