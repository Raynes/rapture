# Rapture

Rapture is a command line tool for pasting to refheap. It is the successor to the
[refh](https://github.com/Raynes/refh) which was written in Haskell.

Haskell was a fine language for this tool, but it was a pain in the ass to
compile for all the various systems I wanted it to work on. It was nothing but
trouble for me. Prior to using Haskell, I used Ruby and Python, and both of
those were fine, but I was really hoping a functional language with fast startup
time and without native compilation would come along and let me rewrite it, and
Elixir filled that hole for me.

## Usage

Rapture is super simple. The only thing you need to run it is Erlang 16B or higher.
Go fetch that. Shouldn't be hard to install at all.

Now you have two options. You can get my cross platform rapture binary from
[here](http://raynes.me/rapture) (just pick the newest version), or you can
get the repo and compile it yourself. If you choose to do the latter, you'll
have to install [Elixir](http://elixir-lang.org) and run `mix escriptize` in the
rapture project directory.

Once you have rapture, just put it somewhere on your PATH and use it like this:

```
$ cat somefile | rapture       # create a paste
$ rapture somefile             # create a paste
$ rapture -p somefile          # create a private paste
$ rapture -l "Elixir" somefile # create a paste with language set to Elixir
$ rapture somefile.ex          # create a paste where language is determined by
                             file extension, Elixir in this case.
```

And that's about it.

## Authentication

If you'd like to paste as your own user, you should go
[get an API key](https://www.refheap.com/api) and then configure rapture to use
it. There are two ways to do this. The best way is to create a file called
`~/.rapture` and put the following in it:

```
your username
your token
```

That's it. Two lines.

The other way you can do this is per-call. You can pass `--user` and `--token`.
