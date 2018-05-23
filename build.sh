#!/bin/bash
declare -A SHED_PKG_LOCAL_OPTIONS=${SHED_PKG_OPTIONS_ASSOC}
# Configure
if [ -n "${SHED_PKG_LOCAL_OPTIONS[toolchain]}" ]; then
    SHED_PKG_LOCAL_PREFIX='/tools'
    sed -i s/mawk// configure &&
    ./configure --prefix=${SHED_PKG_LOCAL_PREFIX} \
                --with-shared   \
                --without-debug \
                --without-ada   \
                --enable-widec  \
                --enable-overwrite || exit 1
else
    SHED_PKG_LOCAL_PREFIX='/usr'
    sed -i '/LIBTOOL_INSTALL/d' c++/Makefile.in &&
    ./configure --prefix=${SHED_PKG_LOCAL_PREFIX}           \
                --mandir=${SHED_PKG_LOCAL_PREFIX}/share/man \
                --with-shared           \
                --without-debug         \
                --without-normal        \
                --enable-pc-files       \
                --enable-widec || exit 1
fi
SHED_PKG_LOCAL_DOCDIR="${SHED_PKG_LOCAL_PREFIX}/share/doc/${SHED_PKG_NAME}-${SHED_PKG_VERSION}"

# Build and Install
make -j $SHED_NUM_JOBS &&
make DESTDIR="$SHED_FAKE_ROOT" install || exit 1

# Rearrange
if [ -z "${SHED_PKG_LOCAL_OPTIONS[toolchain]}" ]; then
    mkdir -v "${SHED_FAKE_ROOT}/lib" &&
    mv -v "${SHED_FAKE_ROOT}/usr/lib/"libncursesw.so.6* "${SHED_FAKE_ROOT}/lib" &&
    ln -sfv ../../lib/$(readlink "${SHED_FAKE_ROOT}/usr/lib/libncursesw.so") "${SHED_FAKE_ROOT}/usr/lib/libncursesw.so" || exit 1
    for lib in ncurses form panel menu ; do
        rm -vf                    "${SHED_FAKE_ROOT}/usr/lib/lib${lib}.so" &&
        echo "INPUT(-l${lib}w)" > "${SHED_FAKE_ROOT}/usr/lib/lib${lib}.so" &&
        ln -sfv ${lib}w.pc        "${SHED_FAKE_ROOT}/usr/lib/pkgconfig/${lib}.pc" || exit 1
    done
    rm -vf                     "${SHED_FAKE_ROOT}/usr/lib/libcursesw.so" &&
    echo "INPUT(-lncursesw)" > "${SHED_FAKE_ROOT}/usr/lib/libcursesw.so" &&
    ln -sfv libncurses.so      "${SHED_FAKE_ROOT}/usr/lib/libcurses.so" || exit 1
fi

# Install Documentation
if [ -n "${SHED_PKG_LOCAL_OPTIONS[docs]}" ]; then
    mkdir -pv "${SHED_FAKE_ROOT}${SHED_PKG_LOCAL_DOCDIR}" &&
    cp -v -R doc/* "${SHED_FAKE_ROOT}/usr/share/doc/ncurses-${SHED_PKG_VERSION}" || exit 1
fi
