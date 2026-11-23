while [ ! -e "$rootMarker" ]; do
  if [ "$PWD" = / ]; then
    printf 'No %s found\n' "$rootMarker" >&2
    exit 1
  fi

  cd ..
done

root=$(pwd -P)

vendor() {
  local path=$1 source=$2 mode destination
  destination=$(realpath -m "$path")

  if [[ "$destination" != "$root/"* ]]; then
    printf 'destination escapes project: %s\n' "$path" >&2
    return 1
  fi

  if [ -d "$source" ]; then
    (
      if [ -d "$path" ] && diff -rq "$source" "$path" >/dev/null; then
        return 0 # permissions/symlink changes won't refresh; eval if desirable
      fi

      parent=$(dirname "$path")
      mkdir -p "$parent"

      staging=$(mktemp -d "$parent/.vendorXXXXXX")
      trap 'rm -rf -- "$staging"' EXIT

      cp -rLT --preserve=mode "$source" "$staging"
      chmod -R u+w "$staging"

      rm -rf "$path"
      mv -T "$staging" "$path"
    )
  else
    mode=644
    if [ -x "$source" ]; then mode=755; fi
    install -CDTm "$mode" "$source" "$path"
  fi
}
