# This file defines two overlays and composes them
{inputs, ...}: let
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs {pkgs = final;};

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # Fix glslviewer audio bug: Remove the incorrect m_dft_buffer = nullptr line
    # that was added in commit 79078eb ("Fix in-class initialization")
    # Bug: https://github.com/patriciogonzalezvivo/glslViewer/issues/...
    glslviewer = prev.glslviewer.overrideAttrs (oldAttrs: {
      postPatch = (oldAttrs.postPatch or "") + ''
        # Remove the incorrect m_dft_buffer = nullptr line that breaks audio
        sed -i 's/    m_dft_buffer = nullptr;//' src/gl/textureStreamAudio.cpp
      '';
    });
  };
in
  inputs.nixpkgs.lib.composeManyExtensions [additions modifications]
