defmodule Rapture do
  def slurp_stdin do
    IO.stream(:stdio) |> Enum.join
  end

  def copy_text(text) do
    copier = case :os.type do
      {:unix, :darwin} -> "pbcopy"
      {:unix, _} -> "xclip"
      _ -> nil
    end
    if copier do
      {x, y, z} = :erlang.now
      timestamp = Enum.reduce([x, y, z], "", fn n, acc -> acc <> integer_to_binary(n) end)
      filename = Path.join(System.tmp_dir, ".rapture-" <> timestamp)
      if File.write(filename, text) == :ok do
        System.cmd "cat #{filename} | #{copier}"
        File.rm filename
        :ok
      else
        :error
      end
    end
  end

  def parse_auth_file(data) do
    lines = String.split(data, "\n")
    if Enum.count(lines) >= 2 do
      {:ok, [username: Enum.at(lines, 0), token: Enum.at(lines, 1)]}
    else
      {:error, :badformat}
    end
  end

  def get_auth_file do
    home = System.user_home
    if home do
      case File.read(Path.join(home, ".rapture")) do
        {:ok, contents} -> parse_auth_file contents
        {:error, _} = error -> error
      end
    else
      {:error, :nohome}
    end
  end

  def get_auth(opts) do
    user = opts[:user]
    token = opts[:token]
    if opts && token do
      [username: user, token: token]
    else
      case get_auth_file do
        {:ok, auth} -> auth
        {:error, _} -> [] # Fine then, no auth. God.
      end
    end
  end

  def get_contents([]), do: slurp_stdin
  def get_contents([file]) do
    path = Path.expand file
    case File.read(path) do
      {:ok, contents} -> contents
      {:error, _} = error -> error
    end
  end

  def get_extension([]), do: nil
  def get_extension([file]), do: Path.extname file

  def format_opts(opts, file) do
    reap_opts = Dict.take(opts, [:language, :private])
    language = reap_opts[:language] || get_extension(file) || "Plain Text"
    Dict.merge(get_auth(opts), reap_opts) |>
    Dict.put(:language, language) |>
    Dict.put(:contents, get_contents(file))
  end


  def create_paste(opts, files) do
    case Reap.request(:post, "/paste", format_opts(opts, files)) do
      {:ok, json} ->
        url = json["url"]
        IO.puts url
        copy_text url
      _           -> IO.puts "The end is neigh."
    end
  end

  def main(opts) do
    Reap.start
    {switches, file} = OptionParser.parse(opts,
      aliases: [l: :language, p: :private, u: :user, t: :token],
      switches: [private: :boolean])
    create_paste switches, file
  end
end
