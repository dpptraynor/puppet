# = Class: ntp
# 
# This class installs/configures/manages NTP. It can optionally disable NTP
# on virtual machines. Only supported on Debian-derived and Red Hat-derived OSes.
# 
# == Parameters: 
#
# $servers:: An array of NTP servers, with or without +iburst+ and 
#            +dynamic+ statements appended. Defaults to the OS's defaults.
# $enable::  Whether to start the NTP service on boot. Defaults to true. Valid
#            values: true and false. 
# $ensure::  Whether to run the NTP service. Defaults to running. Valid values:
#            running and stopped. 
# 
# == Requires: 
# 
# Nothing.
# == Sample Usage:
#
#   class {'ntp':
#     servers => [ "ntp1.example.com dynamic",
#                  "ntp2.example.com dynamic", ],
#   }
#   class {'ntp':
#     enable => false,
#     ensure => stopped,
#   }
#
 class ntp ($servers = undef, $enable = true, $ensure = running) {
      case $operatingsystem {
        centos, redhat, fedora: { 
          $service_name = 'ntpd'
          $conf_template    = 'ntp.conf.redhat.erb'
          $default_servers = [ "0.centos.pool.ntp.org",
                               "1.centos.pool.ntp.org",
                               "2.centos.pool.ntp.org", ]
        }
        debian, ubuntu: { 
          $service_name = 'ntp'
          $conf_file    = 'ntp.conf.deb'
          $conf_template    = 'ntp.conf.deb.erb'
          $default_servers = [ "0.debian.pool.ntp.org",
                               "1.debian.pool.ntp.org",
                               "2.debian.pool.ntp.org", ]
        }
      }

      if $servers == undef {
        $servers_real = $default_servers
      }
      else {
        $servers_real = $servers
      }
            
      package { 'ntp':
        ensure => installed,
      }
      
if $is_virtual == 'true' {
        service {'ntp':
        name   => $service_name,
        ensure => stopped,
        enable => false,
        }
}
else {
        service { 'ntp':
        name       => $service_name,
        ensure     => running,
        enable     => true,
        hasrestart => true,
        require => Package['ntp'],
        subscribe  => File['ntp.conf'],
        }
}

      file { 'ntp.conf':
        path    => '/etc/ntp.conf',
        ensure  => file,
        require => Package['ntp'],
        content => template("ntp/${conf_template}"),
#        source  => "/home/traynor/learning-manifests/${conf_file}",
#        source   => "puppet:///modules/ntp/${conf_file}",
      }
    }
