defmodule PhoenixPlaygroundWeb.HomeLive do
  alias PhoenixPlayground.TogetherAi
  use PhoenixPlaygroundWeb, :live_view

  def mount(_params, _session, socket) do
    socket =
      socket |> assign(:loading, false) |> assign(:text, "")

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-3xl my-20">
      <div class="flex items-start space-x-4">
        <div class="min-w-0 flex-1">
          <form phx-change="validate" phx-submit="submit" id="prompt-form" class="relative">
            <div class="">
              <label for="prompt" class="sr-only">Add your prompt</label>
              <input
                type="text"
                name="prompt"
                id="prompt"
                class="block w-full "
                placeholder="Let me know what you want to achieve"
              />
            </div>

            <div class="flex-shrink-0">
              <button
                :if={not @loading}
                type="submit"
                class="inline-flex items-center rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600"
              >
                Send
              </button>
              <button
                :if={@loading}
                type="submit"
                class="inline-flex items-center rounded-md bg-indigo-300 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600"
              >
                Loading...
              </button>
            </div>
          </form>
        </div>
      </div>

      <p :if={not is_nil(@text)}><%= @text %></p>
    </div>
    """
  end

  def handle_event("validate", _, socket) do
    {:noreply, socket}
  end

  def handle_event("submit", %{"prompt" => prompt}, socket) do
    TogetherAi.stream_completion(prompt, self())

    socket =
      socket |> update(:loading, &toggle_loading/1)

    {:noreply, socket}
  end

  def handle_info({PhoenixPlayground.TogetherAi, "chunk", text}, socket) when is_binary(text) do
    socket =
      socket |> update(:text, &(&1 <> text))

    {:noreply, socket}
  end

  def handle_info({PhoenixPlayground.TogetherAi, "last_chunk", text}, socket)
      when is_binary(text) do
    socket =
      socket
      |> update(:text, &(&1 <> text))
      |> update(:loading, &toggle_loading/1)
      |> put_flash(:info, "Finished generating")

    {:noreply, socket}
  end

  def handle_info({PhoenixPlayground.TogetherAi, :error, error_msg}, socket) do
    socket = socket |> put_flash(:error, error_msg)
    {:noreply, socket}
  end

  def handle_info(_msg, socket) do
    # message that come here unhandled are:
    # 1. {:DOWN, _ref, :process, _pid, :normal}
    # 2. {_ref, {:ok, response = %Req.Response{}}}

    {:noreply, socket}
  end

  # def handle_info({:DOWN, _ref, :process, _pid, :normal}, socket) do
  #   {:noreply, socket}
  # end

  # TODO: Task.async results in :error
  # def handle_info({_ref, {:ok, response = %Req.Response{status: 200}}}, socket) do
  #   {:noreply, socket}
  # end

  defp toggle_loading(curr) when is_boolean(curr) do
    not curr
  end
end
