#!perl
# t/misc.t - Test functionality for which we do not yet have a better place to
# put the tests
use strict;
use warnings;

use Data::Dumper;
use Test::More qw(no_plan); # tests => 10;
use lib qw( ./t/lib );
use Testing qw( _dumptostr );

my ($a, $b, @c, %d);
$a = 'alpha';
$b = 'beta';
@c = ( qw| gamma delta epsilon | );
%d = ( zeta => 'eta', theta => 'iota' );

note("Argument validation for new()");
{
    local $@ = '';
    eval { my $obj = Data::Dumper->new(undef); };
    like($@,
        qr/^Usage:\s+PACKAGE->new\(ARRAYREF,\s*\[ARRAYREF\]\)/,
        "Got error message: new() needs defined argument"
    );
}

{
    local $@ = '';
    eval { my $obj = Data::Dumper->new( { $a => $b } ); };
    like($@,
        qr/^Usage:\s+PACKAGE->new\(ARRAYREF,\s*\[ARRAYREF\]\)/,
        "Got error message: new() needs array reference"
    );
}

{
    note("\$Data::Dumper::Useperl, Useqq, Deparse");
    my ($obj, %dumpstr);

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

{
    note("\$Data::Dumper::Pad and \$obj->Pad");
    my ($obj, %dumps, $pad);
    $obj = Data::Dumper->new([$a,$b]);
    $dumps{'noprev'} = _dumptostr($obj);

    $obj = Data::Dumper->new([$a,$b]);
    $obj->Pad(undef);
    $dumps{'undef'} = _dumptostr($obj);

    $obj = Data::Dumper->new([$a,$b]);
    $obj->Pad('');
    $dumps{'emptystring'} = _dumptostr($obj);

    is($dumps{'noprev'}, $dumps{'undef'},
        "No setting for \$Data::Dumper::Pad and Pad(undef) give same result");

    is($dumps{'noprev'}, $dumps{'emptystring'},
        "No setting for \$Data::Dumper::Pad and Pad('') give same result");

    $pad = 'XXX: ';
    local $Data::Dumper::Pad = $pad;
    $obj = Data::Dumper->new([$a,$b]);
    $dumps{'ddp'} = _dumptostr($obj);
    local $Data::Dumper::Pad = '';

    $obj = Data::Dumper->new([$a,$b]);
    $obj->Pad($pad);
    $dumps{'obj'} = _dumptostr($obj);

    is($dumps{'ddp'}, $dumps{'obj'},
        "\$Data::Dumper::Pad and \$obj->Pad() give same result");

    is( (grep {! /^$pad/} (split(/\n/, $dumps{'ddp'}))), 0,
        "Each line of dumped output padded as expected");
}

{
    note("\$Data::Dumper::Varname and \$obj->Varname");
    my ($obj, %dumps, $varname);
    $obj = Data::Dumper->new([$a,$b]);
    $dumps{'noprev'} = _dumptostr($obj);

    $obj = Data::Dumper->new([$a,$b]);
    $obj->Varname(undef);
    $dumps{'undef'} = _dumptostr($obj);

    $obj = Data::Dumper->new([$a,$b]);
    $obj->Varname('');
    $dumps{'emptystring'} = _dumptostr($obj);

    is($dumps{'noprev'}, $dumps{'undef'},
        "No setting for \$Data::Dumper::Varname and Varname(undef) give same result");

    # Because Varname defaults to '$VAR', providing an empty argument to
    # Varname produces a non-default result.
    isnt($dumps{'noprev'}, $dumps{'emptystring'},
        "No setting for \$Data::Dumper::Varname and Varname('') give different results");

    $varname = 'MIMI';
    local $Data::Dumper::Varname = $varname;
    $obj = Data::Dumper->new([$a,$b]);
    $dumps{'ddv'} = _dumptostr($obj);
    local $Data::Dumper::Varname = undef;

    $obj = Data::Dumper->new([$a,$b]);
    $obj->Varname($varname);
    $dumps{'varname'} = _dumptostr($obj);
    
    is($dumps{'ddv'}, $dumps{'varname'},
        "Setting for \$Data::Dumper::Varname and Varname() give same result");

    is( (grep { /^\$$varname/ } (split(/\n/, $dumps{'ddv'}))), 2,
        "All lines of dumped output use provided varname");

    is( (grep { /^\$VAR/ } (split(/\n/, $dumps{'ddv'}))), 0,
        "No lines of dumped output use default \$VAR");
}

