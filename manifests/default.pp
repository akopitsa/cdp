package {'mc':
  ensure => 'present'
}
file {'/etc/puppetlabs/code/environments/production/manifests/init.pp':
  ensure => file,
  owner => 'root',
  group => 'root',
  mode => '0644',
  content => "node default {include '::ntp'}"
}
