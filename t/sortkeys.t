#!./perl -w
# t/sortkeys.t - Test Sortkeys()

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

use Data::Dumper;
use Test::More qw(no_plan); # tests =>  8;
use lib qw( ./t/lib );
use Testing qw( _dumptostr );

my %d = (
    delta   => 'd',
    beta    => 'b',
    gamma   => 'c',
    alpha   => 'a',
);

{
    my ($obj, %dumps, $sortkeys, $starting);

    note("\$Data::Dumper::Sortkeys and Sortkeys() set to true value");
    note("XS implementation");
    $Data::Dumper::Useperl = 0;

    $starting = $Data::Dumper::Sortkeys;
    $sortkeys = 1;
    local $Data::Dumper::Sortkeys = $sortkeys;
    $obj = Data::Dumper->new( [ \%d ] );
    $dumps{'ddskone'} = _dumptostr($obj);
    local $Data::Dumper::Sortkeys = $starting;

    $obj = Data::Dumper->new( [ \%d ] );
    $obj->Sortkeys($sortkeys);
    $dumps{'objskone'} = _dumptostr($obj);

    is($dumps{'ddskone'}, $dumps{'objskone'},
        "\$Data::Dumper::Sortkeys = 1 and Sortkeys(1) are equivalent");
    like($dumps{'ddskone'},
        qr/alpha.*?beta.*?delta.*?gamma/s,
        "Sortkeys returned hash keys in Perl's default sort order");
    %dumps = ();

    note("Perl implementation");
    $Data::Dumper::Useperl = 1;

    $starting = $Data::Dumper::Sortkeys;
    $sortkeys = 1;
    local $Data::Dumper::Sortkeys = $sortkeys;
    $obj = Data::Dumper->new( [ \%d ] );
    $dumps{'ddskone'} = _dumptostr($obj);
    local $Data::Dumper::Sortkeys = $starting;

    $obj = Data::Dumper->new( [ \%d ] );
    $obj->Sortkeys($sortkeys);
    $dumps{'objskone'} = _dumptostr($obj);

    is($dumps{'ddskone'}, $dumps{'objskone'},
        "\$Data::Dumper::Sortkeys = 1 and Sortkeys(1) are equivalent");
    like($dumps{'ddskone'},
        qr/alpha.*?beta.*?delta.*?gamma/s,
        "Sortkeys returned hash keys in Perl's default sort order");
}

{
    my ($obj, %dumps, $starting);

    note("\$Data::Dumper::Sortkeys and Sortkeys() set to coderef");
    sub reversekeys { return [ reverse sort keys %{+shift} ]; }

    note("XS implementation");
    $Data::Dumper::Useperl = 0;

    $starting = $Data::Dumper::Sortkeys;
    local $Data::Dumper::Sortkeys = \&reversekeys;
    $obj = Data::Dumper->new( [ \%d ] );
    $dumps{'ddsksub'} = _dumptostr($obj);
    local $Data::Dumper::Sortkeys = $starting;

    $obj = Data::Dumper->new( [ \%d ] );
    $obj->Sortkeys(\&reversekeys);
    $dumps{'objsksub'} = _dumptostr($obj);

    is($dumps{'ddsksub'}, $dumps{'objsksub'},
        "\$Data::Dumper::Sortkeys = CODEREF and Sortkeys(CODEREF) are equivalent");
    like($dumps{'ddsksub'},
        qr/gamma.*?delta.*?beta.*?alpha/s,
        "Sortkeys returned hash keys per sorting subroutine");
    %dumps = ();

    note("Perl implementation");
    $Data::Dumper::Useperl = 1;

    $starting = $Data::Dumper::Sortkeys;
    local $Data::Dumper::Sortkeys = \&reversekeys;
    $obj = Data::Dumper->new( [ \%d ] );
    $dumps{'ddsksub'} = _dumptostr($obj);
    local $Data::Dumper::Sortkeys = $starting;

    $obj = Data::Dumper->new( [ \%d ] );
    $obj->Sortkeys(\&reversekeys);
    $dumps{'objsksub'} = _dumptostr($obj);

    is($dumps{'ddsksub'}, $dumps{'objsksub'},
        "\$Data::Dumper::Sortkeys = CODEREF and Sortkeys(CODEREF) are equivalent");
    like($dumps{'ddsksub'},
        qr/gamma.*?delta.*?beta.*?alpha/s,
        "Sortkeys returned hash keys per sorting subroutine");
}

{
    my ($obj, %dumps, $starting);

    note("\$Data::Dumper::Sortkeys and Sortkeys() set to coderef with filter");
    sub reversekeystrim {
        my $hr = shift;
        my @keys = sort keys %{$hr};
        shift(@keys);
        return [ reverse @keys ];
    }

    note("XS implementation");
    $Data::Dumper::Useperl = 0;

    $starting = $Data::Dumper::Sortkeys;
    local $Data::Dumper::Sortkeys = \&reversekeystrim;
    $obj = Data::Dumper->new( [ \%d ] );
    $dumps{'ddsksub'} = _dumptostr($obj);
    local $Data::Dumper::Sortkeys = $starting;

    $obj = Data::Dumper->new( [ \%d ] );
    $obj->Sortkeys(\&reversekeystrim);
    $dumps{'objsksub'} = _dumptostr($obj);

    is($dumps{'ddsksub'}, $dumps{'objsksub'},
        "\$Data::Dumper::Sortkeys = CODEREF and Sortkeys(CODEREF) select same keys");
    like($dumps{'ddsksub'},
        qr/gamma.*?delta.*?beta/s,
        "Sortkeys returned hash keys per sorting subroutine");
    unlike($dumps{'ddsksub'},
        qr/alpha/s,
        "Sortkeys filtered out one key per request");
    %dumps = ();

    note("Perl implementation");
    $Data::Dumper::Useperl = 1;

    $starting = $Data::Dumper::Sortkeys;
    local $Data::Dumper::Sortkeys = \&reversekeystrim;
    $obj = Data::Dumper->new( [ \%d ] );
    $dumps{'ddsksub'} = _dumptostr($obj);
    local $Data::Dumper::Sortkeys = $starting;

    $obj = Data::Dumper->new( [ \%d ] );
    $obj->Sortkeys(\&reversekeystrim);
    $dumps{'objsksub'} = _dumptostr($obj);

    is($dumps{'ddsksub'}, $dumps{'objsksub'},
        "\$Data::Dumper::Sortkeys = CODEREF and Sortkeys(CODEREF) select same keys");
    like($dumps{'ddsksub'},
        qr/gamma.*?delta.*?beta/s,
        "Sortkeys returned hash keys per sorting subroutine");
    unlike($dumps{'ddsksub'},
        qr/alpha/s,
        "Sortkeys filtered out one key per request");
}

note("Internal subroutine _sortkeys");
my %e = (
    nu      => 'n',
    lambda  => 'l',
    kappa   => 'k',
    mu      => 'm',
    omicron => 'o',
);
my $rv = Data::Dumper::_sortkeys(\%e);
is(ref($rv), 'ARRAY', "Data::Dumper::_sortkeys returned an array ref");
is_deeply($rv, [ qw( kappa lambda mu nu omicron ) ],
    "Got keys in Perl default order");
