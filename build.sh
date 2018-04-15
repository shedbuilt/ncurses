#!/bin/bash
case "$SHED_BUILD_MODE" in
    toolchain)
        sed -i s/mawk// configure
        ./configure --prefix=/tools \
                    --with-shared   \
                    --without-debug \
                    --without-ada   \
                    --enable-widec  \
                    --enable-overwrite || return 1
        ;;
    *)
        sed -i '/LIBTOOL_INSTALL/d' c++/Makefile.in
        ./configure --prefix=/usr           \
                    --mandir=/usr/share/man \
                    --with-shared           \
                    --without-debug         \
                    --without-normal        \
                    --enable-pc-files       \
                    --enable-widec || return 1
        ;;
esac
make -j $SHED_NUM_JOBS || return 1
make DESTDIR="$SHED_FAKE_ROOT" install || return 1

if [ "$SHED_BUILD_MODE" != 'toolchain' ]; then
    mkdir -v "${SHED_FAKE_ROOT}/lib"
    mv -v ${SHED_FAKE_ROOT}/usr/lib/libncursesw.so.6* ${SHED_FAKE_ROOT}/lib
    ln -sfv ../../lib/$(readlink ${SHED_FAKE_ROOT}/usr/lib/libncursesw.so) ${SHED_FAKE_ROOT}/usr/lib/libncursesw.so
    for lib in ncurses form panel menu ; do
        rm -vf                    ${SHED_FAKE_ROOT}/usr/lib/lib${lib}.so
        echo "INPUT(-l${lib}w)" > ${SHED_FAKE_ROOT}/usr/lib/lib${lib}.so
        ln -sfv ${lib}w.pc        ${SHED_FAKE_ROOT}/usr/lib/pkgconfig/${lib}.pc
    done
    rm -vf                     ${SHED_FAKE_ROOT}/usr/lib/libcursesw.so
    echo "INPUT(-lncursesw)" > ${SHED_FAKE_ROOT}/usr/lib/libcursesw.so
    ln -sfv libncurses.so      ${SHED_FAKE_ROOT}/usr/lib/libcurses.so
    # Install documentation
    mkdir -pv ${SHED_FAKE_ROOT}/usr/share/doc/ncurses-6.1
    cp -v -R doc/* ${SHED_FAKE_ROOT}/usr/share/doc/ncurses-6.1
fi
