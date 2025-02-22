{ lib
, stdenv
, fetchurl
, meson
, ninja
, gettext
, itstool
, pkg-config
, libxml2
, libjpeg
, libpeas
, libportal-gtk3
, gnome
, gtk3
, libhandy
, glib
, gsettings-desktop-schemas
, gnome-desktop
, lcms2
, gdk-pixbuf
, exempi
, shared-mime-info
, wrapGAppsHook
, librsvg
, libexif
, gobject-introspection
, gi-docgen
}:

stdenv.mkDerivation rec {
  pname = "eog";
  version = "42.0";

  outputs = [ "out" "dev" "devdoc" ];

  src = fetchurl {
    url = "mirror://gnome/sources/${pname}/${lib.versions.major version}/${pname}-${version}.tar.xz";
    sha256 = "sha256-+zW/tRZ6QhIfWae5t6wNdbvQUXua/W2Rgx6E01c13fg=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gettext
    itstool
    wrapGAppsHook
    libxml2 # for xmllint for xml-stripblanks
    gobject-introspection
    gi-docgen
  ];

  buildInputs = [
    libjpeg
    libportal-gtk3
    gtk3
    libhandy
    gdk-pixbuf
    glib
    libpeas
    librsvg
    lcms2
    gnome-desktop
    libexif
    exempi
    gsettings-desktop-schemas
    shared-mime-info
  ];

  mesonFlags = [
    "-Dgtk_doc=true"
  ];

  preFixup = ''
    gappsWrapperArgs+=(
      # Thumbnailers
      --prefix XDG_DATA_DIRS : "${gdk-pixbuf}/share"
      --prefix XDG_DATA_DIRS : "${librsvg}/share"
      --prefix XDG_DATA_DIRS : "${shared-mime-info}/share"
    )
  '';

  postFixup = ''
    # Cannot be in postInstall, otherwise _multioutDocs hook in preFixup will move right back.
    moveToOutput "share/doc" "$devdoc"
  '';

  passthru = {
    updateScript = gnome.updateScript {
      packageName = pname;
      attrPath = "gnome.${pname}";
    };
  };

  meta = with lib; {
    description = "GNOME image viewer";
    homepage = "https://wiki.gnome.org/Apps/EyeOfGnome";
    license = licenses.gpl2Plus;
    maintainers = teams.gnome.members;
    platforms = platforms.unix;
  };
}
