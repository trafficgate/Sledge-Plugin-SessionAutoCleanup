use strict;
use Test::More 'no_plan';

use lib 't/lib';

package Mock::Pages;
use base qw(Sledge::TestPages);

use vars qw($SESSION_TIMEOUT $SESSION_CLEANUP_INTERVAL $TMPL_PATH);
BEGIN {
    $SESSION_TIMEOUT = 120;
    $SESSION_CLEANUP_INTERVAL = 128;
    $TMPL_PATH = "t/template";
}

use Sledge::Plugin::SessionAutoCleanup;

package Sledge::TestSession;

sub cleanup {
    my($self, $page, $min) = @_;
    ::isa_ok $page, 'Mock::Pages';
    ::is $min, 120, "min is 120";
    die "dummy";
}

package main;

eval {
    local *Sledge::Plugin::SessionAutoCleanup::_pid = sub { 128 };
    my $p = Mock::Pages->new;
    $p->dispatch('bar');
};

like $@, qr/dummy/;



