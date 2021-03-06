#!/bin/bash
set -e
EM_DIR=~/src/emscripten

do_config() {
# something wrong with emcc + cproto, use gcc as CPP instead
CPPFLAGS="-DFEAT_GUI_BROWSER" \
CPP="gcc -E" \
$EM_DIR/emconfigure ./configure \
    --enable-gui=browser \
    --with-features=small \
    --disable-xsmp \
    --disable-xmp-interact \
    --disable-luainterp \
    --disable-mzschemeinterp \
    --disable-perlinterp \
    --disable-pythoninterp \
    --disable-python3interp \
    --disable-tclinterp \
    --disable-rubyinterp \
    --disable-cscope \
    --disable-workshop \
    --disable-netbeans \
    --disable-sniff \
    --disable-multibye \
    --disable-hangulinput \
    --disable-xim \
    --disable-fontset \
    --disable-gtktest \
    --disable-largefile \
    --disable-acl \
    --disable-gpm \
    --disable-sysmouse \
    --disable-nls \
    --with-modified-by="Lu Wang" \
    --with-compiledby="Lu Wang" \

}

do_make() {
$EM_DIR/emmake make
}

do_link() {
pushd web
cp ../src/vim vim.bc
$EM_DIR/emcc vim.bc \
    -o vim-1.js\
    --closure 0 \
    --js-library vim_lib.js \
    --post-js vim_post.js \
    -s EXPORTED_FUNCTIONS="['_main', '_input_available', '_gui_browser_handle_key', '_gui_resize_shell']" \
    --embed-file root/.vimrc \
    --embed-file root/.vim \

popd
}

do_transform() {
pushd web

echo "Transfoming..."
js transform.js vim-1.js vim-2._js

echo "Compiling with streamline.js...(very slow)"
_node -c vim-2._js

popd
}

do_compress() {
pushd web 

echo "Optimizing with closure compiler"
java -jar $EM_DIR/third_party/closure-compiler/compiler.jar \
    --language_in ECMASCRIPT5 \
    --js vim-2.js\
    --js_output_file vim.js \
    --externs externs.js \

popd
}

#do_config
do_make
do_link
do_transform
do_compress
