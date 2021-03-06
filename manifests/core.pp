# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include p9_instance_setup::core
class p9_instance_setup::core (
  String $test_user = "tester",
  ) {

  include ntp

  class { selinux:
    mode => 'permissive',
    module_build_root => '/opt/puppetlabs/puppet/cache',
  }

  class { 'timezone':
    timezone => 'America/Los_Angeles',
  }

  class { 'firewalld': 
    default_zone => "trusted",
  }

  user { $test_user:
    ensure           => "present",
    home             => "/home/$test_user",
    password         => "!!",
    password_max_age => "99999",
    password_min_age => "0",
    shell            => "/bin/bash",
    managehome       => true,
  }

  file { "$test_user ssh":
    path    => "/home/$test_user/.ssh",
    owner   => $test_user,
    group   => $test_user,
    source  => "/home/centos/.ssh",
    recurse => true,
  }

  file { "root ssh authorized_keys":
    path    => "/root/.ssh/authorized_keys",
    source  => "/home/centos/.ssh/authorized_keys",
    replace => true,
  }

  file { "$test_user git":
    ensure  => "directory",
    path    => "/home/$test_user/git",
    owner   => $test_user,
    group   => $test_user,
  }

  class { "sudo": }
  sudo::conf { "centos":
    priority => 50,
    content  => "centos ALL=(ALL) NOPASSWD: ALL",
  }
  sudo::conf { $test_user:
    priority => 60,
    content  => "$test_user ALL=(ALL) NOPASSWD: ALL",
  }

  class { "tmux": 
    ensure => true,
  }
  
  include git

  class { 'rbenv': }
  rbenv::plugin { [ 'rbenv/rbenv-vars', 'rbenv/ruby-build' ]: }
  rbenv::build { '2.3.0': global => true }
  rbenv::gem { 'beaker': ruby_version => '2.3.0' }

  class { 'java' :
    package => 'java-1.8.0-openjdk-devel',
  }

  include nginx

  include pdk
}
