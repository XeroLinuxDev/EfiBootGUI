# Maintainer: DarkXero <https://xerolinux.xyz>
pkgname=efibootmgrgui
pkgver=1.0.5
pkgrel=1
pkgdesc="A GUI for managing UEFI/EFI boot entries on Linux — no terminal required"
arch=('x86_64')
url="https://github.com/XeroLinuxDev/EfiBootGUI"
license=('GPL-3.0-or-later')
depends=(
    'efibootmgr'
    'qt6-base'
    'qt6-declarative'
    'polkit'
)
makedepends=(
    'cmake'
    'ninja'
    'qt6-tools'
    'git'
)
optdepends=(
    'kf6-kwindowsystem: blur/transparency support on KWin'
    'kdesu: graphical privilege elevation on KDE Plasma'
)
source=("git+$url.git")
sha256sums=('SKIP')

build() {
    cmake -B build -S "EfiBootGUI" \
        -G Ninja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=/usr
    cmake --build build
}

package() {
    DESTDIR="$pkgdir" cmake --install build

    install -Dm644 "EfiBootGUI/efibootmgrgui.desktop" \
        "$pkgdir/usr/share/applications/efibootmgrgui.desktop"

    install -Dm644 "EfiBootGUI/assets/logo.png" \
        "$pkgdir/usr/share/icons/hicolor/256x256/apps/efibootmgrgui.png"
}
