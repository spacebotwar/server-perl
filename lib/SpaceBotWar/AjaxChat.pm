package SpaceBotWar::AjaxChat;

use Moose;
use MooseX::NonMoose;

extends 'Plack::Component';
use Carp;
use Plack::Response;
use Try::Tiny;
use JSON;
use Data::Dumper;
use Chat::iFly;

use SpaceBotWar;


sub log {
    my ($self) = @_;

    return Log::Log4perl->get_logger( "AjaxChat" );
}

has chat => (
    is      => 'rw',
    default => sub {
        my ($self) = @_;
        my $chat = Chat::iFly->new(
            api_key                 => 'YewMTa7GJlrX-hBTFCLnCDoj5qW9M2IRBC35nlcbRBMW6301',
            static_asset_base_uri   => 'http://spacebotwar.com:5001/ifly',
            ajax_uri                => 'http://spacebotwar.com:5001/ajax/chat',
        );
    },
);

sub BUILD {
    my ($self) = @_;

    $self->log->debug("BUILD AjaxChat");
}


# This is where all the work gets done. 
#
sub call {
    my ($self, $env) = @_;

    my $log = $self->log;
    $log->debug(Dumper(\$env));
    my $user = $self->chat->generate_anonymous_user;
    my $json = $self->chat->render_ajax($user);

    $log->debug("AJAX CHAT [$json]");
    return [ 200, ['Content-Type','application/json'], [$json]];
}

1;
