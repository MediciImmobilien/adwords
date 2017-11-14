defmodule Oauth2 do
    @token_url "https://accounts.google.com/o/oauth2/token"
    @headers %{"Content-Type" => "application/x-www-form-urlencoded"}
    @scope "https://www.googleapis.com/auth/adwords"
	
	def payload(config), do: %{client_id: config[:client_id],client_secret: config[:client_secret],refresh_token: config[:refresh_token],grant_type: "refresh_token",scope: @scope}|> URI.encode_query

    def access_token(config), do: post(@token_url, payload(config), @headers)
	
	def post(url,body,headers), do: HTTPoison.post!(url, body, headers) |> Map.get(:body) |> Poison.decode! |> Map.get("access_token")
end