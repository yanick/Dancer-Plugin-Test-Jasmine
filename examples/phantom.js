use strict;
use warnings;

use Test::More;

use JSON qw/ from_json /;

use WWW::Mechanize::PhantomJS;
use Dancer::Plugin::Test::Jasmine::Results;


my $mech = WWW::Mechanize::PhantomJS->new;
$mech->get('http://localhost:3000?test=hello');

jasmine_results( from_json
    $mech->eval_in_page('jasmine.getJSReportAsString()') 
);

done_testing;
