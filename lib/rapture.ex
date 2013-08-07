defmodule Rapture do

  @version "0.1.3"

  def slurp_stdin do
    IO.stream(:stdio) |> Enum.join
  end

  def copy_text(text) do
    copier = case :os.type do
      {:unix, :darwin} -> "pbcopy"
      {:unix, _} -> "xclip -selection clipboard"
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

  def get_config do
    home = System.user_home
    if home do
      case File.read(Path.join(home, ".rapture")) do
        {:ok, contents} ->
          case :etoml.parse(contents) do
            {:ok, config} -> config
            _ -> []
          end
        {:error, _} -> []
      end
    else
      []
    end
  end

  def get_auth(opts, config) do
    user = opts[:user] || config["user"]
    token = opts[:token] || config["token"]
    if user && token do
      [username: user, token: token]
    else
      [] # No auth.
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

  def format_opts(opts, config, file) do
    reap_opts = Dict.take(opts, [:language, :private])
    language = reap_opts[:language] || get_extension(file) || "Plain Text"
    Dict.merge(get_auth(opts, config), reap_opts) |>
    Dict.put(:language, language) |>
    Dict.put(:contents, get_contents(file))
  end

  def create_paste(opts, files) do
    config = get_config
    url = opts[:url] || config["url"] || "https://www.refheap.com/api"
    case Reap.request(:post, "/paste", format_opts(opts, config, files), url) do
      {:ok, json} ->
        url = json["url"]
        IO.puts url
        unless opts[:no_copy], do: copy_text url
      _           -> IO.puts "The end is neigh."
    end
  end

  def help do
    """
    rapture v#{@version}

    Options:
     -p, --private:  If passed, makes the paste private.
     -l, --language: Sets the paste language. Defaults to "Plain Text".
     -u, --user:     Sets the authenticating user. Always used with --token.
     -t, --token:    Sets the authenticating token. Always used with --user.
     -c, --no-copy:  Don't automatically copy to the clipboard.
     --url:          Specify a non-default refheap API url.

    If no file argument is passed, rapture listens on stdin for text
    and pastes it when it receives EOF. If a file is passed, the
    contents of that file are pasted and, assuming no --language arg
    was passed, an attempt is made to determine the language based
    on file extension.

    After the paste is created, rapture will print the URL to the
    paste and will try to copy it to the clipboard using pbcopy on
    OS X and xclip on other unixes. If the OS is not unix, no
    attempt is made to copy to clipboard.
    """
  end

  def main(opts) do
    Reap.start
    {switches, file} = OptionParser.parse(opts,
      aliases: [l: :language, p: :private, u: :user, t: :token, h: :help,
                c: :no_copy, v: :version],
      switches: [private: :boolean])
    cond do
      switches[:help] -> IO.puts help
      switches[:version] -> IO.puts @version
      true -> create_paste switches, file
    end
  end
end
