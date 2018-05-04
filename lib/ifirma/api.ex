defmodule Ifirma.Api do
  @moduledoc false

  @baseUrl "https://www.ifirma.pl/iapi"

  @type key :: Ifirma.Api.Key.t()

  @type t :: %__MODULE__{
               username: String.t(),
               key: key
             }

  defstruct username: nil,
            key: nil,
            url: nil


  @spec new(username:: String.t(), key:: key, url:: String.t()) :: Ifirma.Api.t()
  def new(username, key, url) do
    %__MODULE__{
      username: username,
      key: key,
      url: url(@baseUrl, url)
    }
  end

  @spec get(__MODULE__.t(), String.t()) :: tuple
  def get(api, url) do
    client(api)
    |> Tesla.get(url)
  end

  @spec client(__MODULE__.t()) :: Tesla.Client.t()
  def client(api)do
    Tesla.build_client([{Tesla.Middleware.Headers, [
      {"content-type", "application/json; charset=utf-8"},
      {"accept", "application/json"}]},
      {Tesla.Middleware.BaseUrl, api.url},
      {Tesla.Middleware.DecodeJson, []},
      {Ifirma.Api.AuthHeader, api}
    ])
  end

  defp url(url1, url2) do
    join = if String.last(url1) == "/", do: "", else: "/"
    url1 <> join <> url2
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

defmodule Ifirma.Api.AuthHeader do
  @behaviour Tesla.Middleware

  def call(env, next, options) do
    env
    |> auth_header(options)
    |> Tesla.run(next)
  end

  defp auth_header(env, opts) do
    message(env, opts)
    |> hmac(opts)
    |> (fn(hash) -> ["IAPIS user=", opts.username, ", hmac-sha1=", hash] end).()
    |> Enum.join()
    |> (fn(val) -> Tesla.put_header(env, "authentication", val) end).()
  end

  defp message(env, opts) do
    [ env.url, opts.username, opts.key.name, env.body ]
    |> Enum.join()
  end

  defp hmac(request, opts) do
    :crypto.hmac(:sha, Base.decode16!(opts.key.value), request)
    |> Base.encode16
    |> String.downcase
  end

end