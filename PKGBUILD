# Maintainer: DarkXero <https://xerolinux.xyz>
pkgname=efibootmgrgui
pkgver=1.0.1
pkgrel=1
pkgdesc="A GUI for managing UEFI/EFI boot entries on Linux — no terminal required"
arch=('x86_64')
url="https://github.com/XeroLinuxDev/EfiBootGUI"
license=('GPL-3.0-or-later')
depends=(
    'efibootmgr'
    'qt6-base'
    'qt6-declarative'
    'kf6-kwindowsystem'
    'kdesu'
)
makedepends=(
    'cmake'
    'ninja'
    'qt6-tools'
)
source=("$pkgname-$pkgver.tar.gz::$url/archive/refs/tags/v$pkgver.tar.gz")
sha256sums=('SKIP')

build() {
    cmake -B build -S "EfiBootGUI-$pkgver" \
        -G Ninja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=/usr
    cmake --build build
}

package() {
    DESTDIR="$pkgdir" cmake --install build
}
