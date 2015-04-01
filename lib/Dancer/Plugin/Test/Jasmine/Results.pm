package Dancer::Plugin::Test::Jasmine::Results;
# ABSTRACT: Turn Jasmine output into TAP results

=head1 SYNOPSIS

    use strict;
    use warnings;

    use Test::More;

    use JSON qw/ from_json /;

    use Test::TCP;
    use WWW::Mechanize::PhantomJS;
    use Dancer::Plugin::Test::Jasmine::Results;

    Test::TCP::test_tcp(
        client => sub {
            my $port = shift;

            my $mech = WWW::Mechanize::PhantomJS->new;

            $mech->get("http://localhost:$port?test=hello");

            jasmine_results from_json
                $mech->eval_in_page('jasmine.getJSReportAsString()'; 
        },
        server => sub {
            my $port = shift;

            use Dancer;
            use MyApp;
            Dancer::Config->load;

            set( startup_info => 0,  port => $port );
            Dancer->dance;
        },
    );

    done_testing;

=head1 DESCRIPTION

Exports the function C<jasmine_results>, which takes
a structure holding the results of Jasmine tests,
and produce the equivalent TAP results.

See L<Dancer::Plugin::Test::Jasmine> for more details.

=cut

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

