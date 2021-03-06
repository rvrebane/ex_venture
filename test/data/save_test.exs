defmodule Data.SaveTest do
  use ExUnit.Case
  import TestHelpers
  doctest Data.Save

  alias Data.Save

  describe "loading" do
    test "converts strings to atoms as keys" do
      {:ok, save} = Data.Save.load(%{"room_id" => 1})
      assert save.room_id == 1
    end

    test "loads stats" do
      {:ok, %Data.Save{stats: stats}} = Data.Save.load(%{"stats" => %{"health" => 50, "strength" => 10, "dexterity" => 10}})

      assert stats == %{health: 50, strength: 10, dexterity: 10}
    end

    test "loads wearing" do
      {:ok, %Data.Save{wearing: %{chest: chest}}} = Data.Save.load(%{"wearing" => %{"chest" => 1}})
      assert chest.id == 1
    end

    test "loads wielding" do
      {:ok, %{wielding: %{right: right}}} = Data.Save.load(%{"wielding" => %{"right" => 1}})
      assert right.id == 1
    end
  end

  test "ensures channels is always an array when loading" do
    {:ok, save} = Save.load(%{})
    assert save.channels == []
  end

  describe "migrate old save data" do
    test "migrate item_ids to item instances" do
      save = %{item_ids: [1], version: 1}
      save = Save.migrate(save)

      assert save.version > 1
      assert [%{id: 1}] = save.items
    end

    test "migrates wearing and wielding items" do
      save = %{wielding: %{right: 1}, wearing: %{chest: 1}}
      save = Save.migrate(save)

      assert save.version > 2
      assert %{right: %{id: 1}} = save.wielding
      assert %{chest: %{id: 1}} = save.wearing
    end

    test "will migrate as far as it can" do
      save = %{item_ids: [1]}
      save = Save.migrate(save)

      assert save.version > 0
      assert [%{id: 1}] = save.items
    end
  end
end
