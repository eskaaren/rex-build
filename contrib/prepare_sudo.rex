# vim: set syn=perl:

use Rex -feature => '1.0';
use Rex::Commands::User;
use YAML;

my $yaml =
  eval { local ( @ARGV, $/ ) = ( $ENV{HOME} . "/.build_config" ); <>; };
$yaml .= "\n";
my $config = Load($yaml);

my $user = $config->{box}->{sudo}->{user};
my $pass = $config->{box}->{sudo}->{password};

if ( exists $ENV{libssh2} ) {
  set connection => 'SSH';
}

user $config->{box}->{default}->{user};
password $config->{box}->{default}->{password};
pass_auth;

group test => $ENV{HTEST};

task prepare => group => test => sub {
  install "sudo";

  create_group $user;

  account $user,
    home        => "/home/$user",
    uid         => 5000,
    groups      => [$user],
    password    => $pass,
    ensure      => "present",
    create_home => TRUE;


  # a user to test sudo -u
  create_group "mytest1";

  account "mytest1",
    home        => "/home/mytest1",
    uid         => 7000,
    groups      => ["mytest1"],
    password    => $pass,
    ensure      => "present",
    create_home => TRUE;

  # need to set_home / always_set_home so that sudo find the right home directory
  my $sudoers_file = "/etc/sudoers";
  if(is_freebsd) {
    $sudoers_file = "/usr/local/etc/sudoers";
  }

  file $sudoers_file,
    content =>
    "Defaults set_home, always_set_home\n\%$user	ALL=(ALL:ALL) ALL\nrsync_user	ALL=(ALL:ALL) ALL\nrsync_user ALL=(ALL:ALL) NOPASSWD: /usr/bin/rsync\nrsync_user ALL=(ALL:ALL) NOPASSWD: /usr/local/bin/rsync\n",
    owner => "root",
    mode  => 440;
};
