use strict;
use Test::More 'no_plan';

use lib 't/lib';

package Mock::Pages;
use base qw(Sledge::TestPages);

use vars qw($SESSION_TIMEOUT $SESSION_CLEANUP_INTERVAL $TMPL_PATH);
BEGIN {
    $SESSION_TIMEOUT = 120;
    $SESSION_CLEANUP_INTERVAL = 32;
    $TMPL_PATH = "t/template";
    $ENV{MOD_PERL} = 1;
}

use Sledge::Plugin::SessionAutoCleanup;

sub dispatch_bar { die 'bar' }

package Sledge::TestSession;

sub cleanup {
    my($self, $page, $min) = @_;
    ::isa_ok $page, 'Mock::Pages';
    ::is $min, 120, "min is 120";
    die "dummy";
}

package main;

my %ex;
for my $i (0..31) {
    eval {
	my $p = Mock::Pages->new;
	$p->dispatch('bar');
    };
    my $res = $@ =~ qr/bar/ ? 1 : 0;
    $ex{$res}++;
}

is $ex{0}, 1;
is $ex{1}, 31;



