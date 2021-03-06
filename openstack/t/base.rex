#
# (c) Jan Gehring <jan.gehring@gmail.com>
#
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:
# vim: set ft=perl:

use strict;
use warnings;

use Rex::Commands::Cloud;
use Rex::Commands::SimpleCheck;
use Rex::Commands::SCM;
use Rex::Commands::Iptables;
use Test::More;
use Data::Dumper;
use YAML;

my $yaml =
  eval { local ( @ARGV, $/ ) = ( $ENV{HOME} . "/.build_config" ); <>; };
$yaml .= "\n";
my $config = Load($yaml);

cloud_service "OpenStack";
cloud_auth %{ $config->{openstack}->{auth} };
cloud_region $config->{openstack}->{endpoint};

user "root";
private_key $config->{amazon}->{auth}->{private_key};
public_key $config->{amazon}->{auth}->{public_key};

task test => sub {
  my $param = shift;

  my @list = cloud_instance_list
    private_network => 'private',
    public_network  => 'private',
    public_ip_type  => 'floating',
    private_ip_type => 'fixed';

  my @images = cloud_image_list;
  my @my_img =
    grep { $_->{name} eq $config->{openstack}->{options}->{image} } @images;
  ok( scalar @my_img == 1, "Got first cloud image." );

  my $vol_id = cloud_volume create =>
    { size => 1, zone => $config->{openstack}->{options}->{volume_zone}, };
  ok( $vol_id =~ m/[a-z0-9\-]+/, "volume-id found" );

  my @vols = cloud_volume_list;
  my @my_vol = grep { $_->{id} eq $vol_id } @vols;

  ok( scalar @my_vol, "found created volume." );

  my $float_ip = get_cloud_floating_ip;
  ok( $float_ip =~ m/^\d+\.\d+\.\d+\.\d+$/, "got a floating ip" );

  my $instance = cloud_instance create => {
    image_id    => $my_img[0]->{id},
    name        => "ostack01",
    plan_id     => $config->{openstack}->{options}->{plan_id},
    volume      => $vol_id,
    floating_ip => $float_ip,
  };

  ok( $instance->{name} eq "ostack01", "got instance name" );

  my ($inst) =
    grep { ( $_->{name} eq "ostack01" ) && ( $_->{state} eq "running" ) }
    cloud_instance_list;

  ok( $inst->{name} eq "ostack01", "got instance name" );

  cloud_instance terminate => $instance->{id};

  ($inst) =
    grep { ( $_->{name} eq "ostack01" ) && ( $_->{state} eq "running" ) }
    cloud_instance_list;

  ok( !$inst, "instance removed" );

  cloud_volume delete => $vol_id;

  @vols = cloud_volume_list;
  @my_vol = grep { $_->{id} eq $vol_id } @vols;

  ok( scalar @my_vol == 0, "deleted my volume." );

  done_testing();
};

1;
