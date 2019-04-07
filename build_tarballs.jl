# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "COINMetisBuilder"
version = v"1.3.5"

# Collection of sources required to build MetisBuilder
sources = [
    "https://github.com/coin-or-tools/ThirdParty-Metis/archive/releases/1.3.5.tar.gz" =>
    "98a6110d5d004a16ad42ee26cfac508477f44aa6fe296b90a6413fe0273ebe24",

]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir
cd ThirdParty-Metis-releases-1.3.5/
./get.Metis 
update_configure_scripts
for path in ${LD_LIBRARY_PATH//:/ }; do
    for file in $(ls $path/*.la); do
        echo "$file"
        baddir=$(sed -n "s|libdir=||p" $file)
        sed -i~ -e "s|$baddir|'$path'|g" $file
    done
done
mkdir build
cd build/
## STATIC BUILD START
if [ $target = "x86_64-apple-darwin14" ]; then
  export AR=/opt/x86_64-apple-darwin14/bin/x86_64-apple-darwin14-ar
fi

../configure --prefix=$prefix --with-pic --disable-pkg-config --host=${target} --disable-shared --enable-static --enable-dependency-linking lt_cv_deplibs_check_method=pass_all
## STATIC BUILD END

## DYNAMIC BUILD START
#../configure --prefix=$prefix --with-pic --disable-pkg-config --host=${target} --enable-shared --disable-static --enable-dependency-linking lt_cv_deplibs_check_method=pass_all
## DYNAMIC BUILD END

make -j${nproc}
make install
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    Linux(:i686, libc=:glibc),
    Linux(:x86_64, libc=:glibc),
    Linux(:aarch64, libc=:glibc),
    Linux(:armv7l, libc=:glibc, call_abi=:eabihf),
    Linux(:powerpc64le, libc=:glibc),
    Linux(:i686, libc=:musl),
    Linux(:x86_64, libc=:musl),
    Linux(:aarch64, libc=:musl),
    Linux(:armv7l, libc=:musl, call_abi=:eabihf),
    MacOS(:x86_64),
    Windows(:i686),
    Windows(:x86_64)
]


# The products that we will ensure are always built
products(prefix) = [
    LibraryProduct(prefix, "libcoinmetis", :libcoinmetis)
]

# Dependencies that must be installed before this package can be built
dependencies = [
    
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)

