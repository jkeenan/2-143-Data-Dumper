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
#    say STDERR "x: @seen";
}
