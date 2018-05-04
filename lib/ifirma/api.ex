defmodule Ifirma.Api do
  @moduledoc false
  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://www.ifirma.pl/iapi"

  @type key :: Ifirma.Api.Key.t()

  @type t :: %__MODULE__{
               username: String.t(),
               key: key
             }

  defstruct username: nil,
            key: nil

  #@spec new(username: String.t(), key: key) :: Ifirma.Api.t()
  def new(username, key) do
    %__MODULE__{
      username: username,
      key: key
    }
  end

  def gett(api, url) do
    api
    |> auth_header('')
    |> (fn(header) -> [{Tesla.Middleware.Headers, [header]}] end).()
    |> Tesla.build_client
    |> get(url)
  end

  defp auth_header(api, request) do
    {"authorization", "IAPIS user=" <> api.username <> " hmac-sha1=" <> hmac(api, request)}
  end

  defp hmac(api, request) do
    :crypto.hmac(:sha, api.key.value, request)
    |> Base.encode16
    |> String.downcase
  end
end

defmodule Ifirma.Api.Key do
  @type t :: %__MODULE__{
            name: String.t(),
            value: String.t()
          }

  defstruct name: nil,
            value: nil
end