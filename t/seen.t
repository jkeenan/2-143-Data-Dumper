#!./perl -w
# t/seen.t - Test Seen()

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
use Test::More qw(no_plan); # tests => 23;
use lib qw( ./t/lib );
use Testing qw( _dumptostr );

my ($obj, %dumps);

#my ($a, $b, $c, @d);
#@d = ('c');
#$c = \@d;
#$b = {};
#$a = [1, $b, $c];
#$b->{a} = $a;
#$b->{b} = $a->[1];
#$b->{c} = $a->[2];
#
#$obj = Data::Dumper->new([$a,$b], [qw(a b)]);
#$obj->Seen({'*c' => $c});
#$dumps{'seenstarc'} = _dumptostr($obj);
##say STDERR $dumps{'seenstarc'};
#
#$obj = Data::Dumper->new([$a,$b], [qw(a b)]);
#$obj->Seen();
#$dumps{'seennoargs'} = _dumptostr($obj);
##say STDERR $dumps{'seennoargs'};

my (@e, %f, @rv, @g, %h);
@e = ( qw| alpha beta gamma | );
%f = ( epsilon => 'zeta', eta => 'theta' );
@g = ( qw| iota kappa lambda | );
%h = ( mu => 'nu', omicron => 'pi' );

#$obj = Data::Dumper->new( [ \@e, \%f ]);
#@rv = $obj->Seen();
#say STDERR "rv: @rv";
#say STDERR "xyz: ", Dumper $obj->{seen};
#$dumps{'seen_array_hash_no_args'} = _dumptostr($obj);
#say STDERR $dumps{'seen_array_hash_no_args'};
#
#$obj = Data::Dumper->new( [ \@e, \%f ], [ '*e', '*f' ]);
#@rv = $obj->Seen();
#say STDERR "rv: @rv";
#say STDERR "xyz: ", Dumper $obj->{seen};
#$dumps{'seen_array_hash_names_no_args'} = _dumptostr($obj);
#say STDERR $dumps{'seen_array_hash_names_no_args'};

{
    my $warning = '';
    local $SIG{__WARN__} = sub { $warning = $_[0] };

    $obj = Data::Dumper->new( [ \@e, \%f ]);
    @rv = $obj->Seen( { mark => 'snark' } );
    like($warning,
        qr/^Only refs supported, ignoring non-ref item \$mark/,
        "Got expected warning for non-ref item");
}

{
    $obj = Data::Dumper->new( [ \@e, \%f ]);
    @rv = $obj->Seen( undef );
    is(@rv, 0, "Seen(undef) returned empty array");
}

{
    $obj = Data::Dumper->new( [ \@e, \%f ]);
    @rv = $obj->Seen( [ qw| mark snark | ] );
    is(@rv, 0, "Seen(ref other than hashref) returned empty array");
}

