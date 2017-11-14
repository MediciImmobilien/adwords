defmodule Adwords do
	@config Application.get_env(:adwords, :adwords)
	
	def test do 
		gclid = "CjwKCAiAxarQBRAmEiwA6YcGKKoG6zRuVf8tjW1PEnggY9WxH_qqIuoRVkVVlvlELuTL_nU_AxU7qxoC_G0QAvD_BwE"
		date = DateTime.utc_now |> convert
		name = "QualifiedLead"
		value = "70"
		currency = "EUR"
		upload(date,name,value,currency, gclid)
	end
	
	def upload(date, nil), do: nil
	
	def format([], acc), do: acc |> Enum.reverse |> List.to_string
	def format([{tag,value}|list],acc \\ []), do: format(list, ["<#{tag}>#{value}</#{tag}>"|acc])
	def name_format(list), do: list |> Enum.map(fn({tag, namespace,value}) -> "<#{tag} #{namespace}>#{value}</#{tag}>" end)
	def format_list(list), do: list |> Enum.map(fn({tag, values}) -> "<#{tag}> #{values |> List.to_string} </#{tag}>" end)
	def format_list_name(list), do: list |> Enum.map(fn({tag,namespace, values}) -> "<#{tag} #{namespace}> #{values |> List.to_string} </#{tag}>" end)
		
	def upload(time,name,value,currency, gclid) do 
		access_token = @config |> Oauth2.access_token()
		headers = [{"Content-Type", "application/soap+xml"},{"Authorization", "Bearer #{access_token}"}]
		namespace = "https://adwords.google.com/api/adwords/cm/v201702"
		header = [{"soapenv:Header",[{"ns1:RequestHeader", "xmlns:ns1='#{namespace}'",[{"ns1:clientCustomerId",@config[:client_customer_id]},{"ns1:developerToken", @config[:developer_token]},{"ns1:userAgent", @config[:user_agent]},{"ns1:validateOnly", "false"},{"ns1:partialFailure", "false"}]|> format }] |> name_format}]|> format		
		body = [{"soapenv:Body", [{"mutate", "xmlns='#{namespace}'", [{"operations", [[{"operator", "ADD"}] |> format,[{"operand", [{"googleClickId",gclid},{"conversionName", name},{"conversionTime", time},{"conversionValue",value},{"conversionCurrencyCode", currency}]|> format}] |> format]}] |> format_list}] |> name_format}]|> format
		payload = ["<?xml version='1.0'?>",[{"soapenv:Envelope", "xmlns:soapenv='http://schemas.xmlsoap.org/soap/envelope/'", [header,body]}]|> format_list_name] |> List.to_string
		url = "https://adwords.google.com/api/adwords/cm/v201702/OfflineConversionFeedService"
		HTTPoison.post(url, payload , headers)
	end

	def convert(%{year: year, month: month, day: day, hour: hour, minute: minute, second: second}), do: "#{year}#{month |> test}#{day|> test} #{hour |> test}#{minute|> test}#{second|> test} Europe/Berlin"
	def test(number) when number < 10, do: "0#{number}"
	def test(number), do: number
end