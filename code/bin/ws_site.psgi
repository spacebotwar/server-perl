#!/usr/bin/env perl

use strict;
use warnings;
use lib "../lib";

use Plack::Builder;
use Plack::App::File;
use Plack::App::IndexFile;


my $app = builder {
    # STatic content
    mount "http://docs.spacebotwar.com/"        => Plack::App::IndexFile->new(root => "/data/space-bot-war/docs/_site")->to_app;
    mount "http://spacebotwar.com/"             => Plack::App::IndexFile->new(root => "/data/space-bot-war-client/src")->to_app;
};
$app;
