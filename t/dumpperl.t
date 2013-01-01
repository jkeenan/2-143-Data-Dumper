#!./perl -w
# test all branches of Dumpperl()
BEGIN {
    if ($ENV{PERL_CORE}){
        require Config; import Config;
        no warnings 'once';
        if ($Config{'extensions'} !~ /\bData\/Dumper\b/) {
            print "1..0 # Skip: Data::Dumper was not built\n";
            exit 0;
        }
    }
}

use strict;
use Carp;
use Data::Dumper;
$Data::Dumper::Indent=1;
use Test::More qw(no_plan); # tests => 9;

my ($a, $b, $obj);
my (@names);
my (@newnames, $objagain, %newnames);
my $dumpstr;
$a = 'alpha';
$b = 'beta';

{
  local $Data::Dumper::Useperl=1;
  my %c = ( eta => 'zeta' );

  $obj = Data::Dumper->new([$a,\%c], [qw(a *c)]);
  $dumpstr = _dumptostr($obj);
#  print STDERR "x: $dumpstr\n";

  $obj = Data::Dumper->new([$a,undef], [qw(a *c)]);
  $dumpstr = _dumptostr($obj);
#  print STDERR "x: $dumpstr\n";
}

pass($0);

sub _dumptostr {
    my ($obj) = @_;
    my $dumpstr;
    open my $T, '>', \$dumpstr or croak "Unable to open for writing to string";
    print $T $obj->Dump;
    close $T or croak "Unable to close after writing to string";
    return $dumpstr;
}
