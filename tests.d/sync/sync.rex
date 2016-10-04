# vim: set syn=perl:
use Rex -feature => 0.42;
use Test::More;

do "auth.conf";

use Cwd 'getcwd';

require SyncFoo;

task "test", group => "test", sub {

  SyncFoo::bar();

  my $ud = "/tmp/etc-$$";
  mkdir $ud;
  my $on_changed_called = 0;
  sync_up "files/etc/", $ud,
        exclude => [ 'exclude-file.*', 'exclude/' ],
        on_change => sub {
          my (@changed_files) = @_;

          my ($found1) = grep { $_ =~ /file1.txt/ } @changed_files;
          my ($found2) = grep { $_ =~ /file2.txt/ } @changed_files;
          my ($found3) = grep { $_ =~ /file3.txt/ } @changed_files;

          ok($found1, "file1.txt was changed");
          ok($found2, "file2.txt was changed");
          ok($found3, "file3.txt was changed");

          $on_changed_called = 1;
        };

  ok($on_changed_called, "on_change was called (sync_up)");
  $on_changed_called = 0;

  ok(!is_file("$ud/exclude-file.txt"), "excluded exclude-file.txt");
  ok(!is_dir("$ud/exclude"), "excluded exclude directory");

  sync_up "files/etc/", $ud,
        on_change => sub {
          my (@changed_files) = @_;
          $on_changed_called = 1;
        };

  ok($on_changed_called == 0, "on_change was not called (sync_up)");
  $on_changed_called = 0;

  my $ds = getcwd() . "/tmp/etc-$$";
  LOCAL { mkdir $ds; };
  sync_down $ud, $ds,
    on_change => sub {
      my (@changed_files) = @_;

      my ($found1) = grep { $_ =~ /file1.txt/ } @changed_files;
      my ($found2) = grep { $_ =~ /file2.txt/ } @changed_files;
      my ($found3) = grep { $_ =~ /file3.txt/ } @changed_files;

      ok($found1, "file1.txt was changed");
      ok($found2, "file2.txt was changed");
      ok($found3, "file3.txt was changed");

      $on_changed_called = 1;
    };

  ok($on_changed_called, "on_change was called (sync_down)");
  $on_changed_called = 0;

  sync_down $ud, $ds,
    on_change => sub {
      my (@changed_files) = @_;
      $on_changed_called = 1;
    };

  ok($on_changed_called == 0, "on_change was not called (sync_down)");
  $on_changed_called = 0;

  rmdir $ds;


  done_testing();

};

1;
