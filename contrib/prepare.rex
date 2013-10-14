# vim: set syn=perl:

use Rex -feature => '0.42';
use Rex::Commands::User;
use YAML;

my $yaml = eval { local(@ARGV, $/) = ($ENV{HOME} . "/.build_config"); <>; };
$yaml .= "\n";
my $config = Load($yaml);

my $user = $config->{box}->{sudo}->{user};
my $pass = $config->{box}->{sudo}->{password};

user $config->{box}->{default}->{user};
password $config->{box}->{default}->{password};
pass_auth;

group test => $ENV{HTEST};

task prepare => group => test => sub {
   # images are absolute minimal

   update_package_db if is_openwrt;

   my @packages = qw/perl rsync/;

   my $additional_packages = case operating_system, {
      qr{centos|redhat}i  => [qw/openssh-clients perl-Data-Dumper/],
      qr{freebsd}i        => [qw/dmidecode/],
      qr{openwrt}i        => [qw/perlbase-bytes perlbase-data perlbase-digest perlbase-essential perlbase-xsloader/],
   };

   push @packages, @{ $additional_packages };

   eval { install \@packages; };

   eval {
      # some tests need this group
      create_group "nobody";

      # some tests need a user
      create_user "nobody",
         groups => ["nobody"];
   };

   run "echo 127.0.2.1 `hostname` >>/etc/hosts";

   mkdir "/tmp2";
};

