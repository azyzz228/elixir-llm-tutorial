defmodule PhoenixPlaygroundWeb.HomeLive do
  use PhoenixPlaygroundWeb, :live_view

  def mount(params, session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <p>Hello</p>
    """
  end
end
