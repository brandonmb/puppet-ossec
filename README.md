# ossec

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)
7. [Release notes](#release-notes)

## Overview

This module installs and configures OSSEC-HIDS client and server.
It requires `puppetlabs/concat`, `puppetlabs/stdlib`, `andyshinn/atomic`, `saz/rsyslog`, `puppetlabs/apt`, and `nanliu/staging`.

## Module Description

This module can be used to install and configure the ossec agent or server.

The agent/client is configured by installing the `ossec::client` class.

Alienvault's ossec repo is the default repo ossec is being installed from. 
This can be overwritten with a custom ppa, apt source, or by installing ossec completely from source.

The server is configured by installing the `ossec::server` class, and using optionally

 * `ossec::command`        : to define active/response command (like firewall-drop.sh)
 * `ossec::activeresponse` : to link rules to active/response command
 * `ossec::email_alert`    : to receive to other email address specific group of rules information
 * `ossec::addlog`         : to add additional localfiles to ossec.conf

## Usage

The class `ossec` controls where ossec is being installed from. 

### SERVER

```puppet
class { 'ossec::server':
  mailserver_ip=>"mailserver.mycompany.com",
  ossec_emailto=>"nicolas.zin@mycompany.com",
}

ossec::command { 'firewallblock':
  command_name       => 'firewall-drop',
  command_executable => 'firewall-drop.sh',
  command_expect     => 'srcip'
}

ossec::activeresponse { 'blockWebattack':
  command_name => 'firewall-drop',
  ar_level     => 9,
  ar_rules_id  => [31153,31151]
}

ossec::addlog { 'mysql_slow':
  logfile => '/var/log/mysql/log-slow-queries.log',
  logtype => 'mysql_log'
}

class {
  'ossec':
    install_from_source => true,
    user_install_type   => server;
  'ossec::server':
    mailserver_ip=>"mailserver.mycompany.com",
    ossec_emailto=>"nicolas.zin@mycompany.com",
}
```

### CLIENT
```puppet
class { 'ossec::client':
  ossec_server_ip => "10.10.130.66"
}

class {
  'ossec':
    install_from_source   => true,
    user_install_type     => 'agent';
  'ossec::client':
    ossec_server_ip       => '10.10.130.66',
    ossec_active_response => false;
}
```

## Reference

### Classes

####Public classes

* `ossec::server`: Installs and configures ossec server.
* `ossec::command` : to define active/response command (like firewall-drop.sh)
* `ossec::activeresponse` : to link rules to active/response command
* `ossec::email_alert` : to receive to other email address specific group of rules information
* `ossec::addlog` : to add additional localfiles to ossec.conf
* `ossec::client` : Installs and configures ossec agent.

####Private classes

* `ossec::server::install`: Installs ossec server.
* `ossec::server::config`: Configures ossec server.
* `ossec::server::key`: Manages ossec agent keys on server.
* `ossec::server::service`: Manages ossec server service.
* `ossec::client::install`: Installs ossec agent.
* `ossec::client::config`: Configures ossec agent.
* `ossec::client::key`: Manages ossec agent keys on client.
* `ossec::client::service`: Manages ossec agent service.

### Parameters

####ossec

These parameters are only useful if you need to change the seed for the agent key
or if you need to change where ossec is installed from.

#####`$agent_seed`

Part of the generated agent key

#####`$comment`, `$custom_apt_source`, `$include_src`, `$key`, `$key_server`, `$location`, `$pin`, `$required_packages`, `$release`, `$repos`

The above variables are all used for defining a custom apt source.
When defining a custom apt source make sure to set `$location`

#####`$custom_apt_ppa`

You can define a custom ppa to use.
```puppet
custom_apt_ppa => 'ppa:nicolas-zin/ossec-ubuntu'
```

#####`$install_from_source`

This allows ossec to be installed from source.

#####`$make_package`

The package(s) you distro needs to be able to use make.

#####`$source_url`, `$target` - Please overwrite defaults with care, and only if needed!!!

Define a source for ossec and then where the extracted files will be staged.

#####`$ossec_version`, `$ossec_extension`

The ossec version and extension of the source file. Ossec version needs to match package version from source URL.

#####`$user_language`, `$user_no_stop`, `$user_install_type`, `$user_dir`, `$user_enable_ar`, `$user_enable_syscheck`
#####`$user_enable_rootcheck`, `$user_update_rules`, `$user_agent_server`

The above variables are used to configure the source installation. Some of these are overwritten by other parts of the module.
When installing the server from source, you will want to overwrite `$user_install_type` to "server"
user_update_rules tells ossec that if it's updating to also update the rules.

See http://ossec-docs.readthedocs.org/en/latest/manual/installation/install-source-unattended.html for more information.

####ossec::server
 
#####`$package_ensure`

(default: `present`) whether package should be installed or removed

#####`$hidsserverpackage`

Hids server package name, defaults to OS default.

#####`hidsserverservice`

Hids server service name.

#####`$ossec_newrules`

Array of new rules if needed.

```puppet
  class 'ossec::server':
    ossec_newrules => [ 'solr_rules.xml', 'confluence_rules.xml' ];
  }
```

#####`$ossec_checkpaths`

Arrays of new paths for ossec to monitor.
```puppet
ossec_checkpaths => [ '/var/vault,/var/lockdown', '/data/safe,/data/supersafe' ]
```

#####`$ossec_ignorepaths`

Array of files to ignore.
```puppet
ossec_checkpaths => [ '/etc/apache/changeAlot', '/etc/monkeybread' ]
```

#####`$new_global`

Needs to contain entire new string for a global setting.
```puppet
new_global => [ '<logall>yes</logall>' ]
```

#####`$restart`

Whether to restart ossec after a change is made

#####`$service_ensure`

(default: `running`) whether service should be running or stopped.

#####`$syscheck_frequency`

(default: 79200) Frequency, in seconds, of syscheck.

#####`$mailserver_ip`

smtp mail server

#####`$ossec_emailfrom`

(default: `ossec@${domain}`) email origin sent by ossec

#####`$ossec_emailto`

who will receive it,

#####`$ossec_active_response`

(default: `true`) if active response should be configure on the server (beware to configure it on clients also)

#####`$ossec_global_host_info_level`

(default: 8) Alerting level for the events generated by the host change monitor (from 0 to 16)

#####`$ossec_global_stat_level`

(default: 8) Alerting level for the events generated by the statistical analysis (from 0 to 16)	

#####`$ossec_email_alert_level`

(default: 7) It correspond to a threshold (from 0 to 156 to sort alert send by email. Some alerts circumvent this threshold (when they have alert_email option)

####ossec::email_alert

#####`$alert_email`

email to send to

#####`$alert_group`

(default: `false`) array of name of rules group 

Caution: no email will be sent when ossec alerts are below global `$ossec_email_alert_level`

About active-response mechanism, check the documentation (and extends the function maybe :-) ): http://www.ossec.net/main/manual/manual-active-responses

####ossec::command

#####`$command_name`

human readable name for `ossec::activeresponse` usage

#####`$command_executable`

name of the executable. Ossec comes preloaded with `disable-account.sh`, `host-deny.sh`, `ipfw.sh`, `pf.sh`, `route-null.sh`, `firewall-drop.sh`, `ipfw_mac.sh`, `ossec-tweeter.sh`, `restart-ossec.sh`

#####`$command_expect`

(default: `srcip`)

#####`$timeout_allowed`

(default: `true`)

####ossec::activeresponse

#####`$command_name`

#####`$ar_location`

(default: `local`) it can be "local","server","defined-agent","all"

#####`$ar_level`

(default: 7) between 0 and 16

######`$ar_rules_id`

(default: `[]`) list of rules id

#####`$ar_timeout`

(default: 300) usually active reponse blocks for a certain amount of time.

####ossec::addlog

#####`$logfile`

Log file to monitor

#####`$logtype`

Type of log file.

You can find more out about ossec log types @ http://ossec-docs.readthedocs.org/en/latest/syntax/head_ossec_config.localfile.html

####ossec::client

#####`$ossec_server_ip`

IP of the server

#####`$ossec_active_response`

(default: true) allows active response on this host

#####`$hidsagentservice`

Ossec agent service name, defaults to OS default (defined in params)

#####`$hidsagentpackage`

Ossec agent package name, defaults to OS default (defined in params)

#####`$package_ensure`

(default: `present`) Whether the package is installed or removed

#####`$ossec_checkpaths`

Arrays of new paths for ossec to monitor.
```puppet
ossec_checkpaths => [ '/var/vault,/var/lockdown', '/data/safe,/data/supersafe' ]
```

#####`$ossec_ignorepaths`

Array of files to ignore.
```puppet
ossec_checkpaths => [ '/etc/apache/changeAlot', '/etc/monkeybread' ]
```

#####`$new_global`

Needs to contain entire new string for a global setting.
```puppet
new_global => [ '<logall>yes</logall>' ]
```

#####`$restart`

Whether to restart ossec after a change is made

#####`$service_ensure`

(default: `running`) whether service should be running or stopped.

#####`$syscheck_frequency`

(default: 79200) Frequency, in seconds, of syscheck.

## Limitations

This module has only been tested against Debian and Redhat derivatives.

## Development

This module was forked from `nzin/puppet-ossec` so I could package it for Puppet Forge. The
original author is [not willing to maintain the code](https://github.com/nzin/puppet-ossec/issues/3)
so please contribute to this fork.

## Todo

## Release Notes

Copyright (C) 2011 Savoir-faire Linux
Author Nicolas Zin
Maintained by Jonathan Gazeley
Licence: GPL v2
