package Dancer::Plugin::Test::Jasmine::Results;

use strict;
use warnings;

use Test::More;

use parent 'Exporter';

our @EXPORT = qw/ jasmine_results /;

sub jasmine_results { 
    my $res = shift;

    subtest $res->{description} || 'jasmine test' => sub {
        diag "duration: ", $res->{durationSec}, "s";
        ok $res->{passed};

        for my $spec ( @{ $res->{specs} } ) {
            subtest $spec->{description} => sub {
                diag "duration: ", $spec->{durationSec}, "s";
                ok $spec->{passed};
            };
        }


       jasmine_results($_) for @{ $res->{suites} };
    };
}

1;

