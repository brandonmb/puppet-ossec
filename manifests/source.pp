# Definition to download and stage source code for ossec

define ossec::source (
  $source_url  = $ossec::source_url,
  $target      = $ossec::target
) {
  include staging

  staging::deploy { "${name}":
    source  => $source_url,
    target  => $target,
  }
}