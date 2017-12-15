#!/bin/bash
sed -i '/LIBTOOL_INSTALL/d' c++/Makefile.in
./configure --prefix=/usr           \
            --mandir=/usr/share/man \
            --with-shared           \
            --without-debug         \
            --without-normal        \
            --enable-pc-files       \
            --enable-widec
make -j $SHED_NUMJOBS
make DESTDIR=$SHED_FAKEROOT install
mkdir -v ${SHED_FAKEROOT}/lib
mv -v ${SHED_FAKEROOT}/usr/lib/libncursesw.so.6* ${SHED_FAKEROOT}/lib
ln -sfv ../../lib/$(readlink ${SHED_FAKEROOT}/usr/lib/libncursesw.so) ${SHED_FAKEROOT}/usr/lib/libncursesw.so
for lib in ncurses form panel menu ; do
    rm -vf                    ${SHED_FAKEROOT}/usr/lib/lib${lib}.so
    echo "INPUT(-l${lib}w)" > ${SHED_FAKEROOT}/usr/lib/lib${lib}.so
    ln -sfv ${lib}w.pc        ${SHED_FAKEROOT}/usr/lib/pkgconfig/${lib}.pc
done
rm -vf                     ${SHED_FAKEROOT}/usr/lib/libcursesw.so
echo "INPUT(-lncursesw)" > ${SHED_FAKEROOT}/usr/lib/libcursesw.so
ln -sfv libncurses.so      ${SHED_FAKEROOT}/usr/lib/libcurses.so
# Install documentation
mkdir -pv ${SHED_FAKEROOT}/usr/share/doc/ncurses-6.0
cp -v -R doc/* ${SHED_FAKEROOT}/usr/share/doc/ncurses-6.0
