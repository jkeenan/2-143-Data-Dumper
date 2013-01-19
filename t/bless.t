#!./perl -w
# t/bless.t - Test Bless()

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
use Test::More tests =>  18;
use lib qw( ./t/lib );
use Testing qw( _dumptostr );

# RT 39420: Data::Dumper fails to escape bless class name
# test under XS and pure Perl version
foreach $Data::Dumper::Useperl (0, 1) {
    note("\$Data::Dumper::Useperl = $Data::Dumper::Useperl");
    
    {
        my $t = bless( {}, q{a'b} );
        my $dt = Dumper($t);
        my $o = <<'PERL';
$VAR1 = bless( {}, 'a\'b' );
PERL
    
        is($dt, $o, "package name in bless is escaped if needed");
        is_deeply(scalar eval($dt), $t, "eval reverts dump");
    }
    
    {
        my $t = bless( {}, q{a\\} );
        my $dt = Dumper($t);
        my $o = <<'PERL';
$VAR1 = bless( {}, 'a\\' );
PERL
    
        is($dt, $o, "package name in bless is escaped if needed");
        is_deeply(scalar eval($dt), $t, "eval reverts dump");
    }
    SKIP: {
        skip(q/no 're::regexp_pattern'/, 1)
            if ! defined(*re::regexp_pattern{CODE});
    
        my $t = bless( qr//, 'foo');
        my $dt = Dumper($t);
        my $o = ($] >= 5.013006 ? <<'PERL' : <<'PERL_LEGACY');
$VAR1 = bless( qr/(?^:)/, 'foo' );
PERL
$VAR1 = bless( qr/(?-xism:)/, 'foo' );
PERL_LEGACY
    
        is($dt, $o, "We can dump blessed qr//'s properly");
    
    }
}

my %d = (
    delta   => 'd',
    beta    => 'b',
    gamma   => 'c',
    alpha   => 'a',
);

{
    my ($obj, %dumps, $bless, $starting);

    note("\$Data::Dumper::Bless and Bless() set to true value");
    note("XS implementation");
    $Data::Dumper::Useperl = 0;

    $starting = $Data::Dumper::Bless;
    $bless = 1;
    local $Data::Dumper::Bless = $bless;
    $obj = Data::Dumper->new( [ \%d ] );
    $dumps{'ddblessone'} = _dumptostr($obj);
    local $Data::Dumper::Bless = $starting;

    $obj = Data::Dumper->new( [ \%d ] );
    $obj->Bless($bless);
    $dumps{'objblessone'} = _dumptostr($obj);

    is($dumps{'ddblessone'}, $dumps{'objblessone'},
        "\$Data::Dumper::Bless = 1 and Bless(1) are equivalent");
    %dumps = ();

    $bless = 0;
    local $Data::Dumper::Bless = $bless;
    $obj = Data::Dumper->new( [ \%d ] );
    $dumps{'ddblesszero'} = _dumptostr($obj);
    local $Data::Dumper::Bless = $starting;

    $obj = Data::Dumper->new( [ \%d ] );
    $obj->Bless($bless);
    $dumps{'objblesszero'} = _dumptostr($obj);

    is($dumps{'ddblesszero'}, $dumps{'objblesszero'},
        "\$Data::Dumper::Bless = 0 and Bless(0) are equivalent");

    $bless = undef;
    local $Data::Dumper::Bless = $bless;
    $obj = Data::Dumper->new( [ \%d ] );
    $dumps{'ddblessundef'} = _dumptostr($obj);
    local $Data::Dumper::Bless = $starting;

    $obj = Data::Dumper->new( [ \%d ] );
    $obj->Bless($bless);
    $dumps{'objblessundef'} = _dumptostr($obj);

    is($dumps{'ddblessundef'}, $dumps{'objblessundef'},
        "\$Data::Dumper::Bless = undef and Bless(undef) are equivalent");
    is($dumps{'ddblesszero'}, $dumps{'objblessundef'},
        "\$Data::Dumper::Bless = undef and = 0 are equivalent");
    %dumps = ();

    note("Perl implementation");
    $Data::Dumper::Useperl = 1;

    $starting = $Data::Dumper::Bless;
    $bless = 1;
    local $Data::Dumper::Bless = $bless;
    $obj = Data::Dumper->new( [ \%d ] );
    $dumps{'ddblessone'} = _dumptostr($obj);
    local $Data::Dumper::Bless = $starting;

    $obj = Data::Dumper->new( [ \%d ] );
    $obj->Bless($bless);
    $dumps{'objblessone'} = _dumptostr($obj);

    is($dumps{'ddblessone'}, $dumps{'objblessone'},
        "\$Data::Dumper::Bless = 1 and Bless(1) are equivalent");
    %dumps = ();

    $bless = 0;
    local $Data::Dumper::Bless = $bless;
    $obj = Data::Dumper->new( [ \%d ] );
    $dumps{'ddblesszero'} = _dumptostr($obj);
    local $Data::Dumper::Bless = $starting;

    $obj = Data::Dumper->new( [ \%d ] );
    $obj->Bless($bless);
    $dumps{'objblesszero'} = _dumptostr($obj);

    is($dumps{'ddblesszero'}, $dumps{'objblesszero'},
        "\$Data::Dumper::Bless = 0 and Bless(0) are equivalent");

    $bless = undef;
    local $Data::Dumper::Bless = $bless;
    $obj = Data::Dumper->new( [ \%d ] );
    $dumps{'ddblessundef'} = _dumptostr($obj);
    local $Data::Dumper::Bless = $starting;

    $obj = Data::Dumper->new( [ \%d ] );
    $obj->Bless($bless);
    $dumps{'objblessundef'} = _dumptostr($obj);

    is($dumps{'ddblessundef'}, $dumps{'objblessundef'},
        "\$Data::Dumper::Bless = undef and Bless(undef) are equivalent");
    is($dumps{'ddblesszero'}, $dumps{'objblessundef'},
        "\$Data::Dumper::Bless = undef and = 0 are equivalent");
    %dumps = ();

}

