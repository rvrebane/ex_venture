defmodule Data.Class do
  @moduledoc """
  Class schema
  """

  use Data.Schema

  alias Data.ClassSkill
  alias Data.Stats

  schema "classes" do
    field(:name, :string)
    field(:description, :string)
    field(:each_level_stats, Stats)

    field(:regen_health, :integer)
    field(:regen_skill_points, :integer)

    has_many(:class_skills, ClassSkill)
    has_many(:skills, through: [:class_skills, :skill])
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [
      :name,
      :description,
      :each_level_stats,
      :regen_health,
      :regen_skill_points
    ])
    |> validate_required([
      :name,
      :description,
      :each_level_stats,
      :regen_health,
      :regen_skill_points
    ])
    |> validate_stats()
  end

  defp validate_stats(changeset) do
    case changeset do
      %{changes: %{each_level_stats: stats}} when stats != nil ->
        _validate_stats(changeset)

      _ ->
        changeset
    end
  end

  defp _validate_stats(changeset = %{changes: %{each_level_stats: stats}}) do
    case Stats.valid_character?(stats) do
      true -> changeset
      false -> add_error(changeset, :each_level_stats, "is invalid")
    end
  end
end
