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

my (@e, %f, @rv, @g, %h, $k);
@e = ( qw| alpha beta gamma | );
%f = ( epsilon => 'zeta', eta => 'theta' );
@g = ( qw| iota kappa lambda | );
%h = ( mu => 'nu', omicron => 'pi' );
sub j { print "Hello world\n"; }
$k = 'just another scalar';

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
    my $warning = '';
    local $SIG{__WARN__} = sub { $warning = $_[0] };

    $obj = Data::Dumper->new( [ \@e, \%f ]);
    @rv = $obj->Seen( { mark => undef } );
    like($warning,
        qr/^Value of ref must be defined; ignoring non-ref item \$mark/,
        "Got expected warning for undefined value of item");
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

{
    $obj = Data::Dumper->new( [ \@e, \%f ]);
    @rv = $obj->Seen( { '*samba' => \@g } );
    is_deeply($rv[0], $obj, "Got the object back: value array ref");
}

{
    $obj = Data::Dumper->new( [ \@e, \%f ]);
    @rv = $obj->Seen( { '*canasta' => \%h } );
    is_deeply($rv[0], $obj, "Got the object back: value hash ref");
}

{
    $obj = Data::Dumper->new( [ \@e, \%f ]);
    @rv = $obj->Seen( { '*pinochle' => \&j } );
    is_deeply($rv[0], $obj, "Got the object back: value code ref");
}

#{
#my $str;
#    $obj = Data::Dumper->new( [ \@e, \%f ]);
#    @rv = $obj->Seen( { '*poker' => \$k } );
#    $str = Dumper($rv[0]);
#print STDERR "after poker: $str\n";
#    is_deeply($rv[0], $obj, "Got the object back: value ref to scalar");
#
#    @rv = $obj->Seen( { '*pinochle' => \&j } );
#    $str = Dumper($rv[0]);
#print STDERR "after pinochle: $str\n";
#
#$obj->Reset;
#    @rv = $obj->Seen();
#    $str = Dumper($rv[0]);
#print STDERR "after empty Seen: $str\n";
#}

