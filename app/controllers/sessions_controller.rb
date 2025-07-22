class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      token = encode_jwt(user_id: user.id)
      render json: { token: token, user: user }, status: :ok
    else
      render json: { error: 'Credenciais inválidas' }, status: :unauthorized
    end
  end

  private

  def encode_jwt(payload)
    JWT.encode(payload, Rails.application.secret_key_base, 'HS256')
  end
end
