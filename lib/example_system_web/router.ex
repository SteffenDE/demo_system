defmodule ExampleSystemWeb.Router do
  use ExampleSystemWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {ExampleSystemWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ExampleSystemWeb do
    pipe_through :browser

    live "/", Math.Sum
    live "/load", Load.Dashboard
    live "/services", Services.Dashboard
  end
end
