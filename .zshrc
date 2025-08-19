# ──────────────────────────────────────────────────────────────────────────────
# 1) Path & core settings
# ──────────────────────────────────────────────────────────────────────────────

# Use GNU tar from Homebrew
export PATH="$(brew --prefix)/opt/gnu-tar/libexec/gnubin:$PATH"
export PATH="/usr/local/sbin:$PATH"

# Hide "user@host" if default user
DEFAULT_USER="$USER"

# Color settings for ls & less
export CLICOLOR=true
export LSCOLORS="exfxcxdxbxegedabagacad"

# Load zsh’s color definitions
autoload colors && colors

# Change to directory if you type its name
setopt auto_cd

# Editor
export EDITOR="vim"

# Git diff shorthand
alias d='git diff'
alias tar='gtar'

# known_hosts cleanup
kh_fix() {
  local line=$1
  if [[ -z "$line" || "$line" -lt 2 ]]; then
    echo "Usage: kh_fix <line number greater than 1>"
    return 1
  fi
  sed -i '' "$((line - 1))d;${line}d" ~/.ssh/known_hosts
}

# Disable Homebrew analytics
export HOMEBREW_NO_ANALYTICS=1

# ──────────────────────────────────────────────────────────────────────────────
# 2) History
# ──────────────────────────────────────────────────────────────────────────────

HISTFILE=$HOME/.zsh_history
HISTSIZE=50000
SAVEHIST=50000

setopt append_history
setopt extended_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_verify
setopt inc_append_history
# setopt share_history    # uncomment to share history across sessions

# ──────────────────────────────────────────────────────────────────────────────
# 3) chruby & Ruby
# ──────────────────────────────────────────────────────────────────────────────

source "$(brew --prefix)/opt/chruby/share/chruby/chruby.sh"
source "$(brew --prefix)/opt/chruby/share/chruby/auto.sh"
chruby ruby-3.3.0

# ──────────────────────────────────────────────────────────────────────────────
# 4) Fast Git completion caching
# ──────────────────────────────────────────────────────────────────────────────

# Homebrew’s zsh completions directory
fpath+=( "$(brew --prefix)/share/zsh/site-functions" )

autoload -Uz compinit
zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path ~/.zsh/.zcompdump
compinit

# ──────────────────────────────────────────────────────────────────────────────
# 5) zsh-autosuggestions (Homebrew)
# ──────────────────────────────────────────────────────────────────────────────

# Must be loaded immediately after compinit
source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
# optional: tweak suggestion color
# export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'

# ──────────────────────────────────────────────────────────────────────────────
# 6) Pure prompt
# ──────────────────────────────────────────────────────────────────────────────

autoload -U promptinit
promptinit
prompt pure

# ──────────────────────────────────────────────────────────────────────────────
# 7) zsh-syntax-highlighting (Homebrew)
# ──────────────────────────────────────────────────────────────────────────────

# Must be last so it picks up all key bindings & prompt setup
source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# ──────────────────────────────────────────────────────────────────────────────
# 8) LESS color support
# ──────────────────────────────────────────────────────────────────────────────

export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

# ──────────────────────────────────────────────────────────────────────────────
# 9) SSH agent
# ──────────────────────────────────────────────────────────────────────────────

# Start agent if needed, then add all private keys in ~/.ssh (skip *.pub, known_hosts, config)
ssh_add_all() {
  # Ensure an agent is available
  if ! ssh-add -l >/dev/null 2>&1; then
    eval "$(ssh-agent -s)" >/dev/null
  fi

  local dir="${1:-$HOME/.ssh}"
  setopt local_options extended_glob null_glob

  # Candidate files: everything except *.pub, known_hosts*, and config*
  local -a candidates
  candidates=(${dir}/^(*.pub|known_hosts(|.*)|config(|.*))(.N))

  if (( ${#candidates} == 0 )); then
    echo "No key files found in $dir"
    return 0
  fi

  # Add only files that look like private keys (by header); ignore failures quietly
  local k first
  for k in "${candidates[@]}"; do
    first="$(head -n1 -- "$k" 2>/dev/null)"
    if [[ "$first" == "-----BEGIN OPENSSH PRIVATE KEY-----" \
       || "$first" == "-----BEGIN RSA PRIVATE KEY-----" \
       || "$first" == "-----BEGIN DSA PRIVATE KEY-----" \
       || "$first" == "-----BEGIN EC PRIVATE KEY-----" ]]; then
      ssh-add --apple-use-keychain "$k" 2>/dev/null || echo "  (skipped: ssh-add failed)"
    fi
  done
}

ssh_add_all

# ──────────────────────────────────────────────────────────────────────────────
# 10) ffmpeg helper functions
# ──────────────────────────────────────────────────────────────────────────────

# --- ffmpeg helpers for Bryce ---

# Ensure ffmpeg/ffprobe exist
_ff_ok() {
  command -v ffmpeg >/dev/null 2>&1 || { echo "❌ ffmpeg not found"; return 127; }
  command -v ffprobe >/dev/null 2>&1 || { echo "❌ ffprobe not found"; return 127; }
}

# Convert 4K → 1080p (scale, CRF 23, preset fast; copy audio)
# Usage: v1080 "Felice I 4K.mp4"
v1080() {
  _ff_ok || return $?
  local in="$*"
  [[ -z "$in" ]] && { echo "Usage: v1080 <input-file>"; return 2; }
  [[ ! -f "$in" ]] && { echo "❌ File not found: $in"; return 1; }

  local dir base ext out
  dir="${in:h}"; base="${in:t}"; ext="${base##*.}"; base="${base%.*}"

  # If filename contains '4K', replace it with '1080p'; else append ' 1080p'
  if [[ "$base" == *"4K"* ]]; then
    out="${base//4K/1080p}.$ext"
  elif [[ "$base" == *"4k"* ]]; then
    out="${base//4k/1080p}.$ext"
  else
    out="${base} 1080p.$ext"
  fi
  out="${dir}/${out}"

  echo "→ Converting to 1080p:"
  echo "ffmpeg -i \"$in\" -vf scale=1920:1080 -c:v libx264 -crf 23 -preset fast -c:a copy \"$out\""
  ffmpeg -i "$in" -vf "scale=1920:1080" -c:v libx264 -crf 23 -preset fast -c:a copy "$out"
}

# --- precise time helpers ---
# Format seconds -> HH:MM:SS.mmm (for display only)
_fmt_hms() {
  perl -e '$s=shift; $s=0 if $s<0;
           $h=int($s/3600); $s-=$h*3600;
           $m=int($s/60);   $s-=$m*60;
           printf("%02d:%02d:%06.3f",$h,$m,$s);' "$1"
}

# Parse "HH:MM:SS[.ms]" or "MM:SS[.ms]" or "seconds" -> seconds (float)
_parse_to_seconds() {
  perl -e '
    my $t=shift;
    if($t =~ /^\d+(?:\.\d+)?$/){ print $t; exit }
    my @p=split(/:/,$t);
    if(@p==3){ print $p[0]*3600 + $p[1]*60 + $p[2]; exit }
    if(@p==2){ print $p[0]*60 + $p[1]; exit }
    die "bad time\n";
  ' "$1"
}

# --- updated no_outro: precise decimals end time passed to ffmpeg ---
# Usage:
#   no_outro "Video.mp4"                # auto: end = duration - NO_OUTRO_LEN (default 29.86s)
#   no_outro "Video.mp4" 01:09:48.250   # manual timestamp
#   no_outro "Video.mp4" 4188.25        # manual seconds
# Optional: export NO_OUTRO_LEN=29.86 to change default outro length
no_outro() {
  _ff_ok || return $?
  local in="$1" manual="$2" outro="${NO_OUTRO_LEN:-29.86}"
  [[ -z "$in" ]] && { echo "Usage: no_outro <input> [HH:MM:SS[.ms] | seconds]"; return 2; }
  [[ ! -f "$in" ]] && { echo "❌ File not found: $in"; return 1; }

  local dir base ext out dur end_s end_hms
  dir="${in:h}"; base="${in:t}"; ext="${base##*.}"; base="${base%.*}"
  out="${dir}/${base} No Outro.${ext}"

  if [[ -n "$manual" ]]; then
    end_s="$(_parse_to_seconds "$manual")" || return 1
    end_hms="$(_fmt_hms "$end_s")"
    echo "→ Using provided end: ${end_hms} (${end_s}s)"
  else
    dur="$(ffprobe -v error -show_entries format=duration -of default=nk=1:nw=1 "$in")" || return $?
    # exact subtraction and round to 3 decimals (millisecond) for ffmpeg -t
    end_s="$(perl -e 'my ($d,$o)=@ARGV; my $e=$d-$o; $e=0 if $e<0; printf "%.3f",$e' "$dur" "$outro")"
    end_hms="$(_fmt_hms "$end_s")"
    echo "→ Video duration: $(_fmt_hms "$dur")"
    echo "→ Outro length:   $(_fmt_hms "$outro")"
    echo "→ New end time:   ${end_hms}"
  fi

  echo "→ Trimming with stream copy:"
  echo "ffmpeg -i \"$in\" -t \"$end_s\" -c copy \"$out\""
  ffmpeg -i "$in" -t "$end_s" -c copy "$out"
}


# Extract audio in its existing format/codec (copies when possible)
# Usage: xaudio "Felice I 4K.mp4"
# Produces same basename with appropriate audio extension.
xaudio() {
  _ff_ok || return $?
  local in="$*"
  [[ -z "$in" ]] && { echo "Usage: xaudio <input-file>"; return 2; }
  [[ ! -f "$in" ]] && { echo "❌ File not found: $in"; return 1; }

  # Get first audio codec
  local codec
  codec="$(ffprobe -v error -select_streams a:0 -show_entries stream=codec_name \
          -of default=nk=1:nw=1 "$in")" || return $?

  local dir base ext out_ext fmt_args
  dir="${in:h}"; base="${in:t}"; base="${base%.*}"

  # Decide container/extension & whether we can stream-copy
  case "$codec" in
    aac)        out_ext="m4a"; fmt_args=(-c:a copy) ;;     # in MP4/MOV usually
    alac)       out_ext="m4a"; fmt_args=(-c:a copy) ;;
    mp3)        out_ext="mp3"; fmt_args=(-c:a copy) ;;
    flac)       out_ext="flac"; fmt_args=(-c:a copy) ;;
    opus)       out_ext="opus"; fmt_args=(-c:a copy) ;;
    vorbis)     out_ext="ogg";  fmt_args=(-c:a copy) ;;
    pcm_s16le)  out_ext="wav";  fmt_args=(-c:a copy -f wav) ;;
    pcm_s24le)  out_ext="wav";  fmt_args=(-c:a copy -f wav) ;;
    pcm_s32le)  out_ext="wav";  fmt_args=(-c:a copy -f wav) ;;
    *)
      # Fallback: extract to WAV (lossless) by decoding
      out_ext="wav"; fmt_args=(-vn -acodec pcm_s16le -f wav)
      echo "ℹ️ Unhandled codec '$codec' → decoding to WAV."
      ;;
  esac

  local out="${dir}/${base}.${out_ext}"
  echo "→ Audio codec: $codec"
  echo "→ Extracting to: $out"
  # -vn to drop video; use chosen args; -y to overwrite if desired (comment out to prevent)
  ffmpeg -i "$in" -vn "${fmt_args[@]}" "$out"
}

# (Optional) Short aliases if you like:
alias ff4k1080='v1080'
alias ffnooutro='no_outro'
alias ffaudio='xaudio'

