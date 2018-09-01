defmodule Rumbl.InfoSys.Wolfram do
  import SweetXml
  alias Rumbl.InfoSys.Result

  def start_link(query, query_ref, owner, limit) do
    Task.start_link(__MODULE__, :fetch, [query, query_ref, owner, limit])
  end

  def fetch(query, query_ref, owner, limit) do
    query
    |> fetch_xml() 
    |> xpath(~x"/queryresult/pod[contains(@title, 'Result') or contains(@title, 'Definitions')]/subpod/plaintext/text()")
    |> send_results(query_ref, owner, limit)
  end

  defp send_results(nil, query_ref, owner, _limit) do
    send(owner, {:results, query_ref, []})
  end

  defp send_results(answer, query_ref, owner, limit) do
    results = [%Result{backend: "wolfram", score: 95, text: to_string(answer)}]
    send(owner, {:results, query_ref, Enum.take(results, limit)})
  end

  defp fetch_xml(query) do
    {:ok, {_, _, body}} = :httpc.request(
      String.to_charlist("http://api.wolframalpha.com/v2/query?appid=#{app_id()}&input=#{URI.encode(query)}&format=plaintext")
    )

    body
  end

  defp app_id, do: Application.get_env(:rumbl, :wolfram)[:app_id]
end
