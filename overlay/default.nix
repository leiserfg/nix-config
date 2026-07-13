# This file defines two overlays and composes them
{inputs, ...}: let
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs {pkgs = final;};

  # Patch for glslviewer audio bug
  glslviewer-audio-patch = final.writeText "glslviewer-fix-audio-nullptr.patch" ''
    --- a/src/gl/textureStreamAudio.cpp
    +++ b/src/gl/textureStreamAudio.cpp
    @@ -58,7 +58,6 @@ TextureStreamAudio::TextureStreamAudio(): TextureStream() {
         m_dft_buffer = (float*)av_malloc_array(sizeof(float), m_buf_len);
         m_buffer_wr.resize(m_buf_len, 0);
         m_buffer_re.resize(m_buf_len, 0);
    -    m_dft_buffer = nullptr;
     }
     
     TextureStreamAudio::~TextureStreamAudio() {
  '';

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # Fix glslviewer audio bug: Remove the incorrect m_dft_buffer = nullptr line
    # that was added in commit 79078eb ("Fix in-class initialization")
    # Bug: https://github.com/patriciogonzalezvivo/glslViewer/issues/...
    glslviewer = prev.glslviewer.overrideAttrs (oldAttrs: {
      patches = (oldAttrs.patches or []) ++ [
        (glslviewer-audio-patch final)
      ];
    });
  };
in
  inputs.nixpkgs.lib.composeManyExtensions [additions modifications]
