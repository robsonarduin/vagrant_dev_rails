$as_vagrant   = 'sudo -u vagrant -H bash -l -c'
$home         = '/home/vagrant'
$user_name    = ''
$user_email   = ''

Exec {
  path => ['/usr/sbin', '/usr/bin', '/sbin', '/bin']
}

# --- Preinstall Stage ---------------------------------------------------------

stage { 'preinstall':
  before => Stage['main']
}

class apt_get_update {
  exec { 'apt-get -y update':
    unless => "test -e ${home}/.rvm"
  }
}
class { 'apt_get_update':
  stage => preinstall
}

# --- Packages -------------------------------------------------------------------
package { ['sqlite3', 'libsqlite3-dev']:
  ensure => installed;
}

#libcurl4-openssl-dev needed by passanger
package { ['curl']:
  ensure => installed
}

package { 'build-essential':
  ensure => installed
}

package { 'git-core':
  ensure => installed
}

# Nokogiri dependencies.
package { ['libxml2', 'libxml2-dev', 'libxslt1-dev']:
  ensure => installed
}

# ExecJS runtime.
package { 'nodejs':
  ensure => installed
}

# --- Ruby ---------------------------------------------------------------------
exec { 'install_rvm':
  command => "${as_vagrant} 'curl -L https://get.rvm.io | bash -s stable'",
  creates => "${home}/.rvm/bin/rvm",
  require => Package['curl']
}

exec { 'install_ruby':
  # We run the rvm executable directly because the shell function assumes an
  # interactive environment, in particular to display messages or ask questions.
  # The rvm executable is more suitable for automated installs.
  #
  # Thanks to @mpapis for this tip.
  command => "${as_vagrant} '${home}/.rvm/bin/rvm install 1.9.3 --latest-binary --autolibs=enabled && rvm --fuzzy alias create default 1.9.3 && rvm use 1.9.3'",
  creates => "${home}/.rvm/bin/ruby",
  require => Exec['install_rvm']
}

exec { 'install_bundler':
  command => "${as_vagrant} 'gem install bundler --no-rdoc --no-ri'",
  creates => "${home}/.rvm/bin/bundle",
  require => Exec['install_ruby']
}

# --- bash_profile
file { "${home}/.bash_profile":
  content => "function parse_git_branch_and_add_brackets {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \\(.*\\)/\\ \\[\\1\\]/'
}
PS1=\"\\h:\\W \\u\\[\\033[0;32m\\]\\$(parse_git_branch_and_add_brackets) \\[\\033[0m\\]\\$ \"
alias ls='ls --color'
[[ -s \"${home}/.rvm/scripts/rvm\" ]] && source \"${home}/.rvm/scripts/rvm\"\n",
  require => Exec['install_bundler']
}

# --- Git config name and email
exec { "git config --global user.name '$user_name'":
  require => Package['git-core']
}

exec { "git config --global user.email '$user_email'":
  require => Package['git-core']
}