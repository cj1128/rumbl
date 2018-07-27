defmodule Rumbl.AccountTest do
  use Rumbl.DataCase

  alias Rumbl.Account
  alias Rumbl.Account.User

  describe "Create User" do
    @valid_attrs %{
      name: "Name",
      username: "username",
      password: "password",
    }
    @invalid_attrs %{}

    test "valid data should be ok" do
      assert {:ok, %User{id: id} = user} = Account.create_user(@valid_attrs)
      assert user.name == "Name"
      assert user.username == "username"
      assert [%User{id: ^id}] = Account.list_users()
    end

    test "invalid data should fail" do
      assert {:error, _} = Account.create_user(@invalid_attrs)
      assert [] = Account.list_users()
    end

    test "username must be unique" do
      assert {:ok, %User{id: id}} = Account.create_user(@valid_attrs)
      assert {:error, changeset} = Account.create_user(@valid_attrs)

      assert %{username: ["has already been taken"]} =
        errors_on(changeset)

      assert [%User{id: ^id}] = Account.list_users()
    end

    test "username must be present" do
      attrs = Map.put(@valid_attrs, :username, "")
      assert {:error, changeset} = Account.create_user(attrs)
      assert %{username: ["can't be blank"]} = errors_on(changeset)
    end

    test "username's length should be <= 20" do
      attrs = Map.put(@valid_attrs, :username, String.duplicate("a", 30))
      assert {:error, changeset} = Account.create_user(attrs)
      assert %{username: ["should be at most 20 character(s)"]} = errors_on(changeset)
    end

    test "password must be present" do
      attrs = Map.put(@valid_attrs, :password, "")
      assert {:error, changeset} = Account.create_user(attrs)
      assert %{password: ["can't be blank"]} = errors_on(changeset)
    end

    test "password's length should be >= 6 && <= 20" do
      attrs = Map.put(@valid_attrs, :password, "a")
      assert {:error, changeset} = Account.create_user(attrs)
      assert %{password: ["should be at least 6 character(s)"]} = errors_on(changeset)

      attrs = Map.put(@valid_attrs, :password, String.duplicate("a", 21))
      assert {:error, changeset} = Account.create_user(attrs)
      assert %{password: ["should be at most 20 character(s)"]} = errors_on(changeset)
    end
  end

  describe "Authenticate User" do
    @username "cj"
    @password "mysecret"

    setup do
      {:ok, user: user_fixture(username: @username, password: @password)}
    end

    test "return user with correct password", %{user: %User{id: id}} do
      assert {:ok, %User{id: ^id}} =
        Account.authenticate_user(@username, @password)
    end

    test "return unauthorized with invalid password" do
      assert {:error, :unauthorized} =
        Account.authenticate_user(@username, "invalidpass")
    end

    test "return not_found with no matching user" do
      assert {:error, :not_found} =
        Account.authenticate_user("invaliduser", @password)
    end
  end
end
