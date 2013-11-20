package SpaceBotWar::Plugin::Modal;

use Mojo::Base 'Mojolicious::Plugin';

sub register {
  my ($plugin, $app) = @_;

  push @{$app->renderer->classes}, __PACKAGE__;

  $app->helper( modal => sub {
    my ($self, $id, $body) = @_;
    $body = $body->() if ref $body;
    return $self->render(
      template => 'spacebotwar_modal',
      partial  => 1,
      'spacebotwar.modal.id'   => $id,
      'spacebotwar.modal.body' => $body,
    );
  });
}

1;

__DATA__

@@ spacebotwar_modal.html.ep
<div class="modal hide fade" id="<%= stash 'spacebotwar.modal.id' %>">
  <div class="modal-header">
    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
    <h3>Confirm Action</h3>
  </div>
  <div class="modal-body">
    <p><%= stash 'spacebotwar.modal.body' %></p>
  </div>
  <div class="modal-footer">
    <a href="#" class="btn" data-dismiss="modal">Close</a>
    <a href="#" class="btn btn-primary" data-dismiss="modal">Confirm</a>
  </div>
</div>
