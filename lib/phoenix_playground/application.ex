defmodule PhoenixPlayground.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      PhoenixPlaygroundWeb.Telemetry,
      # Start the Ecto repository
      PhoenixPlayground.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: PhoenixPlayground.PubSub},
      # Start Finch
      {Finch, name: PhoenixPlayground.Finch},
      # Start the Endpoint (http/https)
      PhoenixPlaygroundWeb.Endpoint
      # Start a worker by calling: PhoenixPlayground.Worker.start_link(arg)
      # {PhoenixPlayground.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PhoenixPlayground.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PhoenixPlaygroundWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
