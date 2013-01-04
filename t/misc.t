#!perl
# t/misc.t - Test functionality for which we do not yet have a better place to
# put the tests
use strict;
use warnings;

use Data::Dumper;
use Test::More qw(no_plan); # tests => 10;
use lib qw( ./t/lib );
use Testing qw( _dumptostr );

my ($a, $b, @c, %d, $obj);
$a = 'alpha';
$b = 'beta';
@c = ( qw| gamma delta epsilon | );
%d = ( zeta => 'eta', theta => 'iota' );
my (@seen);

{
    local $@ = '';
    eval { $obj = Data::Dumper->new(undef); };
    like($@,
        qr/^Usage:\s+PACKAGE->new\(ARRAYREF,\s*\[ARRAYREF\]\)/,
        "Got error message: new() needs defined argument"
    );
}

{
    local $@ = '';
    eval { $obj = Data::Dumper->new( { $a => $b } ); };
    like($@,
        qr/^Usage:\s+PACKAGE->new\(ARRAYREF,\s*\[ARRAYREF\]\)/,
        "Got error message: new() needs array reference"
    );
}

{
    local $@ = '';
    $obj = Data::Dumper->new( [ \@c, \%d ], [ qw| *c *d | ] );
    $obj->Dump;
    @seen = $obj->Seen();
    # Am not yet sure what Seen() is really supposed to do.
#    say STDERR "x: @seen";
#    say STDERR Dumper(\@seen);
}

{
    my %dumpstr;

    local $Data::Dumper::Useperl = 1;
    $obj = Data::Dumper->new( [ \@c, \%d ] );
    $dumpstr{useperl} = [ $obj->Values ];
    local $Data::Dumper::Useperl = 0;

    local $Data::Dumper::Useqq = 1;
    $obj = Data::Dumper->new( [ \@c, \%d ] );
    $dumpstr{useqq} = [ $obj->Values ];
    local $Data::Dumper::Useqq = 0;

    is_deeply($dumpstr{useperl}, $dumpstr{useqq},
        "Useperl and Useqq return same");

    local $Data::Dumper::Deparse = 1;
    $obj = Data::Dumper->new( [ \@c, \%d ] );
    $dumpstr{deparse} = [ $obj->Values ];
    local $Data::Dumper::Deparse = 0;

    is_deeply($dumpstr{useperl}, $dumpstr{deparse},
        "Useperl and Deparse return same");

}

