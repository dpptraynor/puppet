class apache {

      case $operatingsystem {
        centos, redhat, fedora: { 
          $service_name = 'httpd'
          $conf_file    = 'httpd.redhat.conf'
        }
        debian, ubuntu: { 
          $service_name = 'apache2'
          $conf_file    = 'httpd.debian.conf'
        }
        default: { fail("Unrecognized operating system for webserver") }
      }

      package {'apache':
        name   => $service_name,
        ensure => latest,
      }

      service { 'apache':
        name      => $service_name,
        ensure    => running,
        enable    => true,
        subscribe => File['httpd.conf'],
      }
      
      file { 'httpd.conf':
        path    => '/etc/httpd/conf/httpd.conf',
        ensure  => file,
        require => Package['apache'],
        source   => "puppet:///modules/apache/${conf_file}",
      }

      file { 'index.html':
        path    => '/var/www/html/index.html',
        ensure  => file,
        require => Package['apache'],
        source   => "puppet:///modules/apache/index.html",
      }
    }

class{'apache':}
