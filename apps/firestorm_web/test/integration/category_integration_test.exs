defmodule FirestormWeb.CategoryIntegrationTest do
  @moduledoc false
  use FirestormWeb.IntegrationCase, async: true
  alias FirestormData.Commands.LoginOrRegisterFromGitHub

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  test "creating a category", %{conn: conn} do
    {:ok, knewter} = create_user("knewter")

    conn
    |> login_as(knewter)
    |> get(category_path(conn, :new))
    |> follow_form(
      %{
        create_category: %{
          title: "My new category"
        }
      },
      %{identifier: category_path(conn, :create)}
    )
    |> assert_response(
      status: 200,
      html: "My new category"
    )
  end

  describe "With some sample data" do
    setup [:create_users, :create_categories_and_threads]

    test "Viewing a category", %{conn: conn, categories: %{elixir: elixir}} do
      conn
      |> get(category_path(conn, :show, elixir.slug))
      |> assert_response(
        status: 200,
        path: category_path(conn, :show, elixir.slug),
        html: elixir.title,
        html: hd(elixir.threads).title,
      )
    end
  end

  def create_user(username) do
    %LoginOrRegisterFromGitHub{}
    |> LoginOrRegisterFromGitHub.changeset(%{username: username, email: "#{username}@example.org"})
    |> LoginOrRegisterFromGitHub.run()
  end
end
