FROM icydee/perl:latest

RUN cpanm Moose
RUN cpanm Twiggy
RUN cpanm Plack
RUN cpanm Server::Starter
RUN cpanm namespace::autoclean
RUN cpanm MooseX::Singleton
RUN cpanm JSON
RUN cpanm UUID::Tiny
RUN cpanm Try
RUN cpanm MooseX::NonMoose
RUN cpanm AnyEvent::WebSocket::Server
RUN cpanm Plack::App::WebSocket::Connection
RUN cpanm Log::Log4perl
RUN cpanm Math::Round
RUN cpanm Test::Compile
RUN cpanm Beanstalk::Client
RUN cpanm YAML
RUN cpanm Config::JSON
RUN cpanm DBIx::Class::Schema
RUN cpanm Crypt::SaltedHash
RUN cpanm --force POE::Filter::JSON
RUN cpanm App::EvalServer
RUN cpanm DBIx::Class::TimeStamp
RUN cpanm DBIx::Class::InflateColumn::Serializer
RUN cpanm Text::Trim
RUN cpanm Data::Validate::Email
RUN cpanm Test::Class::Moose
RUN cpanm Email::Valid
RUN cpanm Test::Number::Delta
RUN cpanm Test::Mock::Class
RUN cpanm DBIx::Class::EasyFixture
RUN cpanm Redis
RUN cpanm Plack::Middleware::Headers
RUN cpanm DBD::mysql
RUN cpanm Devel::Cover
