package Dancer::Plugin::Test::Jasmine;
# ABSTRACT: Inject and run Jasmine tests in your web pages

=head1 SYNOPSIS

=head1 DESCRIPTION

=cut

use strict;
use warnings;

use File::ShareDir::Tarball;

use Dancer ':syntax';
use Dancer::Plugin;
use Path::Tiny;

use Moo;
with 'MooX::Singleton';

has library_dir => (
    is => 'ro',
    lazy => 1,
    default => sub {
        path(
            plugin_setting->{lib_dir} 
                || File::ShareDir::Tarball::dist_dir('Dancer-Plugin-Test-Jasmine') 
        );
    },
);

has specs_dir => (
    is => 'ro',
    lazy => 1,
    default => sub {
        path( config->{appdir}, plugin_setting->{specs_dir} || 't/specs' );
    },
);

has url_prefix => (
    is => 'ro',
    lazy => 1,
    default => sub {
        plugin_setting->{url_prefix} || '/test';
    },
);

my $plugin = __PACKAGE__->instance;

hook before => sub {
    var jasmine_tests => param('test') ? [ param_array('test') ] : undef;
};

register jasmine_includes => sub { 
    return '' unless var 'jasmine_tests';

    my $prefix = $plugin->url_prefix;

    return <<"END";
        <link rel="stylesheet" href="$prefix/lib/jasmine.css">
        <script src="$prefix/lib/jasmine.js"></script>e
        <script src="$prefix/lib/jasmine-html.js"></script>
        <script src="$prefix/lib/boot.js"></script>
        <script src="$prefix/lib/jasmine-jsreporter.js"></script>
        <style>
            div.jasmine_html-reporter {
                position:  absolute;
                top: 0px;
                left: 0px;
                width: 400px;
                border: 1px solid black;
                background-color: white;
                padding: 3em;
            }
        </style>
END
};

register jasmine_tests => sub { 
    my $tests =  var 'jasmine_tests' or return '';

    my $prefix = $plugin->url_prefix;

    my $js = <<'END';
        <script>
        jasmine.getEnv().addReporter(new jasmine.JSReporter2());
        </script>
END

    $js .= $_ for map { qq{<script src="$prefix/specs/$_"></script>} } 
                  map { $_ . '.js' } @$tests;

    return $js;
};

prefix $plugin->url_prefix => sub {

    get '/lib/:file' => sub {
        my $file = $plugin->library_dir->child(param 'file');
        
        send_error "file not found", 404 unless -f $file;

        send_file $file, system_path => 1;
    };

    get '/specs/**' =>  sub {
        my $file = $plugin->specs_dir->child( @{ (splat())[0] } );

        send_error "file not found", 404 unless -f $file;

        send_file $file, system_path => 1;
    };


};



register_plugin;

1;
