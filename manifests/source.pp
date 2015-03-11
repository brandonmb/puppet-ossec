# Definition to download and stage source code for ossec

define ossec::source (
  $source_url  = $ossec::source_url,
  $target      = $ossec::target
) {
  include staging

$preloaded_content = "${ossec::client::user_language}
${ossec::user_no_stop}
${ossec::user_install_type}
${ossec::user_dir}
${ossec::user_enable_ar}
${ossec::user_enable_syscheck}
${ossec::user_enable_rootcheck}
${ossec::user_update_rules}
${ossec::user_agent_server}"

  staging::deploy { "$name":
    source  => $source_url,
    target  => $target,
  } ->

  file {
    "${ossec::target}/${ossec::ossec_version}/etc/preloaded-vars.conf":
      content => $preloaded_content,
  }
  
}