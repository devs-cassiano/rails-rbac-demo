module RoleAuthorization
  extend ActiveSupport::Concern

  included do
    # Exemplo de uso: before_action -> { require_role(:admin) }, only: [:destroy]
  end

  def require_role(*roles)
    unless current_user && roles.map(&:to_s).include?(current_user.role)
      render json: { error: 'Not Authorized' }, status: :forbidden
    end
  end

  def require_self_or_role(*roles)
    unless current_user && (current_user == @user || roles.map(&:to_s).include?(current_user.role))
      render json: { error: 'Not Authorized' }, status: :forbidden
    end
  end
end
