defmodule Ifirma.Invoice do
  @moduledoc false
  
  use ExActor.GenServer, export: {:global, :ifirma_invoice}

  defstart start_link do
    key = %Ifirma.Api.Key{
      name: "faktura",
      value: Application.get_env(:ifirma, "key")
    }
    state = Ifirma.Api.new(
      Application.get_env(:ifirma, "user"),
      key
    )
    initial_state(state)
  end

  defcall list, state: state do
    reply(state)
  end
end