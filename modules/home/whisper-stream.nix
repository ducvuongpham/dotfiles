{ pkgs, ... }:
# whisper.cpp realtime streaming, exposed as `live-translate`.
#
# Defaults: base model (~150 MB, fast, lower accuracy), translate-to-English
# on, keep context across chunks. Model auto-downloads to
# ~/.cache/whisper-cpp/models on first run.
# Swap up via env var: `WHISPER_MODEL=large-v3-turbo live-translate` (~1.5 GB,
# much better Japanese) or `WHISPER_MODEL=large-v3 live-translate` (~3 GB).
#
# Audio capture requires a Mac audio device. To listen to mic + speaker
# simultaneously, create an Aggregate Device in Audio MIDI Setup combining
# your mic and BlackHole 2ch (BlackHole installed via homebrew cask), then
# pass its index with `-c N`. Run `live-translate` once and read the
# capture-device list it prints at startup to find the index.
#
# Usage:
#   live-translate                          # default device, any → English
#   live-translate -c 2                     # use capture device index 2
#   live-translate -c 2 -l ja               # force Japanese as source
#   WHISPER_MODEL=large-v3 live-translate   # bigger model (~3 GB)
#   live-translate --no-translate           # transcribe in source lang only
let
  liveTranslate = pkgs.writeShellApplication {
    name = "live-translate";
    runtimeInputs = [ pkgs.whisper-cpp pkgs.coreutils ];
    text = ''
      MODEL_DIR="$HOME/.cache/whisper-cpp/models"
      MODEL_NAME="''${WHISPER_MODEL:-base}"
      MODEL_PATH="$MODEL_DIR/ggml-$MODEL_NAME.bin"

      mkdir -p "$MODEL_DIR"

      if [ ! -f "$MODEL_PATH" ]; then
        echo "[live-translate] downloading $MODEL_NAME model to $MODEL_DIR ..." >&2
        whisper-cpp-download-ggml-model "$MODEL_NAME" "$MODEL_DIR"
      fi

      TRANSLATE_FLAG="--translate"
      EXTRA_ARGS=()

      while [ "$#" -gt 0 ]; do
        case "$1" in
          --no-translate) TRANSLATE_FLAG=""; shift ;;
          *)              EXTRA_ARGS+=("$1"); shift ;;
        esac
      done

      ARGS=(-m "$MODEL_PATH" --keep-context --step 3000 --length 10000)
      [ -n "$TRANSLATE_FLAG" ] && ARGS+=("$TRANSLATE_FLAG")

      exec whisper-stream "''${ARGS[@]}" "''${EXTRA_ARGS[@]}"
    '';
  };
in
{
  home.packages = [ pkgs.whisper-cpp liveTranslate ];
}
