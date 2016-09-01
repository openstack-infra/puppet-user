# usage
#
# user::virtual::localuser['username']

define user::virtual::localuser(
  $gid,
  $realname,
  $sshkeys,
  $uid,
  $groups     = [ 'sudo', 'admin', 'adm', ],
  $home       = "/home/${title}",
  $key_id     = $title,
  $key_type   = 'ssh-rsa',
  $managehome = true,
  $old_keys   = [],
  $shell      = '/bin/bash',
) {

  group { $title:
    ensure => present,
    gid    => $gid,
  }

  user { $title:
    ensure     => present,
    comment    => $realname,
    uid        => $uid,
    gid        => $gid,
    groups     => $groups,
    home       => $home,
    managehome => $managehome,
    membership => 'minimum',
    shell      => $shell,
    require    => Group[$title],
  }

  # ensure that home exists with the right permissions
  file { $home:
    ensure  => directory,
    owner   => $title,
    group   => $title,
    mode    => '0755',
    require => [ User[$title], Group[$title] ],
  }

  # Ensure the .ssh directory exists with the right permissions
  file { "${home}/.ssh":
    ensure  => directory,
    owner   => $title,
    group   => $title,
    mode    => '0700',
    require => File[$home],
  }

  ssh_authorized_key { $key_id:
    ensure  => present,
    key     => $sshkeys,
    user    => $title,
    type    => $key_type,
    require => File[ "${home}/.ssh" ],
  }

  if ( $old_keys != [] ) {
    ssh_authorized_key { $old_keys:
      ensure => absent,
      user   => $title,
    }
  }
}

# vim:sw=2:ts=2:expandtab:textwidth=79
