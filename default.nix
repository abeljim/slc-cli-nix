{pkgs ? import <nixpkgs> {}}:
pkgs.stdenv.mkDerivation {
  pname = "slc-cli";
  version = "5.10.2.0";

  src = pkgs.fetchurl {
    url = "https://github.com/abeljim/slc-cli-nix/releases/download/v5.10.2.0/slc_cli_linux_5.10.2.0.zip";
    sha256 = "12w0c5l0nkm90v3j0xir04wrm32yyf5j33b89n9z84qawqbbacdm";
  };

  buildInputs = [
    pkgs.libarchive
    pkgs.jdk17
  ];

  unpackPhase = ''
    bsdtar -xf $src
  '';

  installPhase = ''
    mkdir -p $out/bin
    mv slc_cli $out/
    chmod +x $out/slc_cli/slc

    # Create a wrapper script for the `slc` command
    cat > $out/bin/slc <<EOF
    #!/bin/bash
    export JAVA_HOME=${pkgs.jdk17}
    export PATH=\$JAVA_HOME/bin:\$PATH
    exec $out/slc_cli/slc "\$@"
    EOF
    chmod +x $out/bin/slc

    ln -s $out/slc_cli/slc.jar $out/bin/slc.jar
  '';

  meta = with pkgs.lib; {
    description = "Silicon Labs C CLI";
    homepage = "https://docs.silabs.com/simplicity-studio-5-users-guide/latest/ss-5-users-guide-tools-slc-cli/";
    license = licenses.unfree;
    platforms = platforms.linux;
    maintainers = with maintainers; [abeljim];
  };
}
