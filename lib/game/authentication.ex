defmodule Game.Authentication do
  @moduledoc """
  Find and validate a user
  """
  import Ecto.Query

  alias Data.Repo
  alias Data.Skill
  alias Data.Stats
  alias Data.User
  alias Game.Account

  @doc """
  Attempt to find a user and validate their password
  """
  @spec find_and_validate(String.t(), String.t()) :: {:error, :invalid} | User.t()
  def find_and_validate(name, password) do
    User
    |> where([u], u.name == ^name)
    |> preloads()
    |> Repo.one()
    |> _find_and_validate(password)
  end

  defp _find_and_validate(nil, _password) do
    Comeonin.Bcrypt.dummy_checkpw()
    {:error, :invalid}
  end

  defp _find_and_validate(user, password) do
    case Comeonin.Bcrypt.checkpw(password, user.password_hash) do
      true ->
        user
        |> set_defaults()
        |> Account.migrate()

      _ ->
        {:error, :invalid}
    end
  end

  @doc """
  Find a user by an id and preload properly
  """
  @spec find_user(integer()) :: nil | User.t()
  def find_user(user_id) do
    User
    |> where([u], u.id == ^user_id)
    |> preloads()
    |> Repo.one()
    |> set_defaults()
    |> Account.migrate()
  end

  defp preloads(query) do
    query
    |> preload([:race])
    |> preload(class: [skills: ^from(s in Skill, order_by: [s.level, s.id])])
  end

  @doc """
  Ensure that the user's stats include all required fields. Uses `Data.Stats.default/1`.
  """
  @spec set_defaults(nil | User.t()) :: nil | User.t()
  def set_defaults(user)
  def set_defaults(nil), do: nil

  def set_defaults(user) do
    stats = user.save.stats |> Stats.default()
    %{user | save: %{user.save | stats: stats}}
  end
end
