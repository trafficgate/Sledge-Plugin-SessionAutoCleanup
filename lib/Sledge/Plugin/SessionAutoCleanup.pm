package Sledge::Plugin::SessionAutoCleanup;

use strict;
use vars qw($VERSION $Default);
$VERSION = 0.02;

$Default = { timeout => 120, interval => 128 };

sub import {
    my $class = shift;
    my $pkg   = caller(0);
    return unless $pkg->can('create_config');

    my $config = $pkg->create_config;
    my $timeout  = eval { $config->session_timeout } || $Default->{timeout};
    my $interval = eval { $config->session_cleanup_interval } || $Default->{interval};

    my $condition;
    if ($ENV{MOD_PERL}) {
	# use closure to share counter
	my $counter = int rand $interval;
	$condition = sub { (++$counter % $interval) == 0 };
    } else {
	# use $$ (PID) to share counter
	$condition = sub { my $pid = _pid(); ($pid % $interval) == 0 };
    }

    $pkg->register_hook(
	BEFORE_DISPATCH => sub {
	    my $self =  shift;
	    if ($condition->()) {
		ref($self->session)->cleanup($self, $timeout);
	    }
	},
    );
}

sub _pid { $$ }			# for easy testing

1;
__END__

=head1 NAME

Sledge::Plugin::SessionAutoCleanup - auto-clean up old sessions

=head1 SYNOPSIS

  package My::Pages;
  use Sledge::Plugin::SessionAutoCleanup;

  # your Config
  $C{SESSION_TIMEOUT}          = 60 * 2; # 120 minutes
  $C{SESSION_CLEANUP_INTERVAL} = 128;	 # cleanup interval

=head1 DESCRIPTION

Session cleanup is done in every C<SESSION_CLEANUP_INTERVAL> requests
(roughly).

=head1 AUTHOR

Tatsuhiko Miyagawa with Sledge devleopers.

=cut
