
using BinDeps
@BinDeps.setup

libhattrie = library_dependency("libhattrie", aliases=["libhat-trie"])
version = "0.1.1"

provides(Sources,
         Dict(URI("https://github.com/dcjones/hat-trie/releases/download/v0.1.1/hat-trie-$version.tar.gz") => libhattrie),
         os=:Unix)

provides(BuildProcess,
    Dict(Autotools(libtarget=joinpath("src", "libhat-trie.la"),
                   configure_options=["--enable-shared=yes"]) => libhattrie))

@BinDeps.install Dict(:libhattrie => :libhattrie)
