class User < ApplicationRecord
  has_secure_password

  validates :email, presence: true, uniqueness: true
  validates :username, presence: true, uniqueness: true
  validates :name, presence: true
  validates :role, presence: true, exclusion: { in: [nil, ""] }

  # Exemplo de roles possíveis
  ROLES = %w[admin manager user guest]

  def role?(base_role)
    role == base_role.to_s
  end
end
