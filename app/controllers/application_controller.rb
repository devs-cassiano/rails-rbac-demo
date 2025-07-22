class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Autenticação por JWT
  def current_user
    return @current_user if defined?(@current_user)
    header = request.headers['Authorization']
    if header.present?
      token = header.split(' ').last
      begin
        decoded = JWT.decode(token, Rails.application.secret_key_base, true, { algorithm: 'HS256' })
        user_id = decoded[0]['user_id']
        @current_user = User.find_by(id: user_id)
      rescue JWT::DecodeError, ActiveRecord::RecordNotFound
        @current_user = nil
      end
    end
    @current_user
  end

  def authenticate_user!
    render json: { error: 'Not Authorized' }, status: :unauthorized unless current_user
  end
end
