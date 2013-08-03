# Sow

Sow is a command line tool for pasting to refheap. It is the successor to the
[refh](https://github.com/Raynes/refh) which was written in Haskell.

Haskell was a fine language for this tool, but it was a pain in the ass to
compile for all the various systems I wanted it to work on. It was nothing but
trouble for me. Prior to using Haskell, I used Ruby and Python, and both of
those were fine, but I was really hoping a functional language with fast startup
time and without native compilation would come along and let me rewrite it, and
Elixir filled that hole for me.

## Usage

Sow is super simple. The only thing you need to run it is Erlang 15 or higher.
Go fetch that. Shouldn't be hard to install at all.

Now you have two options. You can get my cross platform sow binary from
[here](http://raynes.me/files/sow) (just pick the newest version), or you can
get the repo and compile it yourself. If you choose to do the latter, you'll
have to install [Elixir](http://elixir-lang.org) and run `mix escriptize` in the
sow project directory.

Once you have sow, just put it somewhere on your PATH and use it like this:

```
$ cat somefile | sow       # create a paste
$ sow somefile             # create a paste
$ sow -p somefile          # create a private paste
$ sow -l "Elixir" somefile # create a paste with language set to Elixir
$ sow somefile.ex          # create a paste where language is determined by
                             file extension, Elixir in this case.
```

And that's about it.
