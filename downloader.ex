defmodule Downloader do
  def download_file(url) do
    headers = []

    file_name =
      url
      |> String.split("/")
      |> List.last()

    path_to_file =
      "./pictures/"
      |> Path.join(file_name)
      |> String.to_charlist()

    if File.exists?(path_to_file) do
      IO.puts("File already exists")
    else
      http_request_opts = []

      case :httpc.request(:get, {url, headers}, http_request_opts, stream: path_to_file) do
        {:ok, :saved_to_file} ->
          IO.puts("Downloaded file: #{file_name}")

        {:ok, _} ->
          IO.puts("Dont know")

        {:error, _} ->
          IO.puts("Failed to download file: #{file_name}")
      end
    end
  end
end

IO.puts("Program started")

:inets.start()
:ssl.start()

## Sync version
# File.stream!("urls.csv")
# |> Stream.map(&String.trim/1)
# |> Enum.uniq()
# |> Stream.each(fn url -> Downloader.download_file(url) end)
# |> Stream.run()

# Async version
File.stream!("urls.csv")
|> Stream.map(&String.trim/1)
|> Enum.uniq()
|> Task.async_stream(fn url -> Downloader.download_file(url) end, max_concurrency: 10)
|> Stream.run()

IO.puts("Program finished")