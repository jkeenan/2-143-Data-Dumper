#!./perl -w
# t/purity_deepcopy.t - Test Purity(), Deepcopy() and recursive structures

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
use Test::More qw(no_plan); # tests => 14;
use lib qw( ./t/lib );
use Testing qw( _dumptostr );

my ($a, $b, $c, @d);

note("\$Data::Dumper::Purity and Purity()");

{
    my ($obj, %dumps, $purity);

    # Adapted from example in Dumper.pm POD:
    @d = ('c');
    $c = \@d;
    $b = {};
    $a = [1, $b, $c];
    $b->{a} = $a;
    $b->{b} = $a->[1];
    $b->{c} = $a->[2];

    $obj = Data::Dumper->new([$a,$b,$c], [qw(a b c)]);
    $dumps{'noprev'} = _dumptostr($obj);

    note("Discrepancy between Dumpxs() and Dumpperl() behavior with respect to \$Data::Dumper::Purity = undef");
    local $Data::Dumper::Useperl = 1;
    $purity = undef;
    local $Data::Dumper::Purity = $purity;
    $obj = Data::Dumper->new([$a,$b,$c], [qw(a b c)]);
    $dumps{'ddpundef'} = _dumptostr($obj);

    $purity = 0;
    local $Data::Dumper::Purity = $purity;
    $obj = Data::Dumper->new([$a,$b,$c], [qw(a b c)]);
    $dumps{'ddpzero'} = _dumptostr($obj);

    is($dumps{'noprev'}, $dumps{'ddpundef'},
        "No previous Purity setting equivalent to \$Data::Dumper::Purity = undef");

    is($dumps{'noprev'}, $dumps{'ddpzero'},
        "No previous Purity setting equivalent to \$Data::Dumper::Purity = 0");
}

{
    my ($obj, %dumps, $purity);

    @d = ('c');
    $c = \@d;
    $b = {};
    $a = [1, $b, $c];
    $b->{a} = $a;
    $b->{b} = $a->[1];
    $b->{c} = $a->[2];

    $obj = Data::Dumper->new([$a,$b,$c], [qw(a b c)]);
    $dumps{'noprev'} = _dumptostr($obj);

    $purity = 0;
    $obj = Data::Dumper->new([$a,$b,$c], [qw(a b c)]);
    $obj->Purity($purity);
    $dumps{'objzero'} = _dumptostr($obj);

    is($dumps{'noprev'}, $dumps{'objzero'},
        "No previous Purity setting equivalent to Purity(0)");

    $purity = undef;
    $obj = Data::Dumper->new([$a,$b,$c], [qw(a b c)]);
    $obj->Purity($purity);
   $dumps{'objundef'} = _dumptostr($obj);

    is($dumps{'noprev'}, $dumps{'objundef'},
        "No previous Purity setting equivalent to Purity(undef)");
}

{
    my ($obj, %dumps, $purity);

    @d = ('c');
    $c = \@d;
    $b = {};
    $a = [1, $b, $c];
    $b->{a} = $a;
    $b->{b} = $a->[1];
    $b->{c} = $a->[2];

    $obj = Data::Dumper->new([$a,$b,$c], [qw(a b c)]);
    $dumps{'noprev'} = _dumptostr($obj);

    $purity = 1;
    local $Data::Dumper::Purity = $purity;
    $obj = Data::Dumper->new([$a,$b,$c], [qw(a b c)]);
    $dumps{'ddpone'} = _dumptostr($obj);

    isnt($dumps{'noprev'}, $dumps{'ddpone'},
        "No previous Purity setting different from \$Data::Dumper::Purity = 1");
}

{
    my ($obj, %dumps, $purity);

    @d = ('c');
    $c = \@d;
    $b = {};
    $a = [1, $b, $c];
    $b->{a} = $a;
    $b->{b} = $a->[1];
    $b->{c} = $a->[2];

    $obj = Data::Dumper->new([$a,$b,$c], [qw(a b c)]);
    $dumps{'noprev'} = _dumptostr($obj);

    $purity = 1;
    $obj = Data::Dumper->new([$a,$b,$c], [qw(a b c)]);
    $obj->Purity(1);
    $dumps{'objone'} = _dumptostr($obj);

    isnt($dumps{'noprev'}, $dumps{'objone'},
        "No previous Purity setting different from Purity(0)");
}

{
    my ($obj, %dumps, $purity);

    @d = ('c');
    $c = \@d;
    $b = {};
    $a = [1, $b, $c];
    $b->{a} = $a;
    $b->{b} = $a->[1];
    $b->{c} = $a->[2];

    $purity = 1;
    local $Data::Dumper::Purity = $purity;
    $obj = Data::Dumper->new([$a,$b,$c], [qw(a b c)]);
    $dumps{'ddpone'} = _dumptostr($obj);
    local $Data::Dumper::Purity = undef;

    $obj = Data::Dumper->new([$a,$b,$c], [qw(a b c)]);
    $obj->Purity(1);
    $dumps{'objone'} = _dumptostr($obj);

    is($dumps{'ddpone'}, $dumps{'objone'},
        "\$Data::Dumper::Purity = 1 and Purity(1) are equivalent");
}

note("\$Data::Dumper::Deepcopy and Deepcopy()");

{
    my ($obj, %dumps, $deepcopy);

    # Adapted from example in Dumper.pm POD:
    @d = ('c');
    $c = \@d;
    $b = {};
    $a = [1, $b, $c];
    $b->{a} = $a;
    $b->{b} = $a->[1];
    $b->{c} = $a->[2];

    $obj = Data::Dumper->new([$a,$b,$c], [qw(a b c)]);
    $dumps{'noprev'} = _dumptostr($obj);

    $deepcopy = undef;
    local $Data::Dumper::Deepcopy = $deepcopy;
    $obj = Data::Dumper->new([$a,$b,$c], [qw(a b c)]);
    $dumps{'dddundef'} = _dumptostr($obj);

    $deepcopy = 0;
    local $Data::Dumper::Deepcopy = $deepcopy;
    $obj = Data::Dumper->new([$a,$b,$c], [qw(a b c)]);
    $dumps{'dddzero'} = _dumptostr($obj);

    is($dumps{'noprev'}, $dumps{'dddundef'},
        "No previous Deepcopy setting equivalent to \$Data::Dumper::Deepcopy = undef");

    is($dumps{'noprev'}, $dumps{'dddzero'},
        "No previous Deepcopy setting equivalent to \$Data::Dumper::Deepcopy = 0");
}

{
    my ($obj, %dumps, $deepcopy);

    @d = ('c');
    $c = \@d;
    $b = {};
    $a = [1, $b, $c];
    $b->{a} = $a;
    $b->{b} = $a->[1];
    $b->{c} = $a->[2];

    $obj = Data::Dumper->new([$a,$b,$c], [qw(a b c)]);
    $dumps{'noprev'} = _dumptostr($obj);

    $deepcopy = 0;
    $obj = Data::Dumper->new([$a,$b,$c], [qw(a b c)]);
    $obj->Deepcopy($deepcopy);
    $dumps{'objzero'} = _dumptostr($obj);

    is($dumps{'noprev'}, $dumps{'objzero'},
        "No previous Deepcopy setting equivalent to Deepcopy(0)");

    $deepcopy = undef;
    $obj = Data::Dumper->new([$a,$b,$c], [qw(a b c)]);
    $obj->Deepcopy($deepcopy);
    $dumps{'objundef'} = _dumptostr($obj);

    is($dumps{'noprev'}, $dumps{'objundef'},
        "No previous Deepcopy setting equivalent to Deepcopy(undef)");
}

{
    my ($obj, %dumps, $deepcopy);

    @d = ('c');
    $c = \@d;
    $b = {};
    $a = [1, $b, $c];
    $b->{a} = $a;
    $b->{b} = $a->[1];
    $b->{c} = $a->[2];

    $obj = Data::Dumper->new([$a,$b,$c], [qw(a b c)]);
    $dumps{'noprev'} = _dumptostr($obj);

    $deepcopy = 1;
    local $Data::Dumper::Deepcopy = $deepcopy;
    $obj = Data::Dumper->new([$a,$b,$c], [qw(a b c)]);
    $dumps{'dddone'} = _dumptostr($obj);

    isnt($dumps{'noprev'}, $dumps{'dddone'},
        "No previous Deepcopy setting different from \$Data::Dumper::Deepcopy = 1");
}

{
    my ($obj, %dumps, $deepcopy);

    @d = ('c');
    $c = \@d;
    $b = {};
    $a = [1, $b, $c];
    $b->{a} = $a;
    $b->{b} = $a->[1];
    $b->{c} = $a->[2];

    $obj = Data::Dumper->new([$a,$b,$c], [qw(a b c)]);
    $dumps{'noprev'} = _dumptostr($obj);

    $deepcopy = 1;
    $obj = Data::Dumper->new([$a,$b,$c], [qw(a b c)]);
    $obj->Deepcopy(1);
    $dumps{'objone'} = _dumptostr($obj);

    isnt($dumps{'noprev'}, $dumps{'objone'},
        "No previous Deepcopy setting different from Deepcopy(0)");
}

{
    my ($obj, %dumps, $deepcopy);

    @d = ('c');
    $c = \@d;
    $b = {};
    $a = [1, $b, $c];
    $b->{a} = $a;
    $b->{b} = $a->[1];
    $b->{c} = $a->[2];

    $deepcopy = 1;
    local $Data::Dumper::Deepcopy = $deepcopy;
    $obj = Data::Dumper->new([$a,$b,$c], [qw(a b c)]);
    $dumps{'dddone'} = _dumptostr($obj);
    local $Data::Dumper::Deepcopy = undef;

    $obj = Data::Dumper->new([$a,$b,$c], [qw(a b c)]);
    $obj->Deepcopy(1);
    $dumps{'objone'} = _dumptostr($obj);

    is($dumps{'dddone'}, $dumps{'objone'},
        "\$Data::Dumper::Deepcopy = 1 and Deepcopy(1) are equivalent");
}

