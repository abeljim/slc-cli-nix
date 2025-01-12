{
  description = "Silicon Labs C CLI";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
  };

  outputs = {
    self,
    nixpkgs,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {system = "x86_64-linux";};
  in {
    packages.${system}.slc-cli = pkgs.stdenv.mkDerivation {
      pname = "slc-cli";
      version = "5.10.0";

      src = pkgs.fetchurl {
        url = "https://www.silabs.com/documents/login/software/slc_cli_linux.zip";
        sha256 = "0zvn4f7942vdiz8j45jilacrs2c6km199h57gr174ci7d026jcd2";
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
    };
    devShells.${system}.default = pkgs.mkShell {
      buildInputs = [
        self.packages.${system}.slc-cli
      ];
    };
  };
}
