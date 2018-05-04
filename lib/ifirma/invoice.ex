defmodule Ifirma.Invoice do
  @moduledoc false
  
  use ExActor.GenServer, export: {:global, :ifirma_invoice}

  defstart start_link do
    key = %Ifirma.Api.Key{
      name: "faktura",
      value: config().key
    }
    state = Ifirma.Api.new(
      config().user,
      key,
      "fakturakraj/"
    )
    initial_state(state)
  end

  defcall list, state: state do
    set_and_reply(state, Ifirma.Api.get(state, "list.json"))
  end

  defp config do
    Application.get_env(:ifirma, __MODULE__)
    |> Map.new
  end
end