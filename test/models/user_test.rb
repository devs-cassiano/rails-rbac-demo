require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "deve ser válido com atributos obrigatórios" do
    user = User.new(
      name: "João",
      username: "joao123",
      email: "joao@email.com",
      password: "senha123",
      role: "user"
    )
    assert user.valid?
  end

  test "deve ser inválido sem email" do
    user = User.new(name: "João", username: "joao123", password: "senha123", role: "user")
    assert_not user.valid?
    assert_includes user.errors[:email], "can't be blank"
  end

  test "deve ser inválido sem username" do
    user = User.new(name: "João", email: "joao@email.com", password: "senha123", role: "user")
    assert_not user.valid?
    assert_includes user.errors[:username], "can't be blank"
  end

  test "deve ser inválido sem name" do
    user = User.new(username: "joao123", email: "joao@email.com", password: "senha123", role: "user")
    assert_not user.valid?
    assert_includes user.errors[:name], "can't be blank"
  end

  test "deve ser inválido sem role" do
    user = User.new(name: "João", username: "joao123", email: "joao@email.com", password: "senha123", role: nil)
    assert_not user.valid?
    assert_includes user.errors[:role], "can't be blank"
  end

  test "deve ser inválido com role em branco" do
    user = User.new(name: "João", username: "joao123", email: "joao@email.com", password: "senha123", role: "")
    assert_not user.valid?
    assert_includes user.errors[:role], "can't be blank"
  end
end
