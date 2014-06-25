package Games::2048::AI::AlphaBeta;
use 5.012;
use Moo;
use Games::AlphaBeta;
use Games::2048::AI::AlphaBeta::Position;
use Storable qw/dclone/;

extends 'Games::2048::Game::Input';

has played    => is => 'rw', default => 1;
has max_plays => is => 'rw', default => 10;

sub handle_input {
	my ($self, $app) = @_;

    my $pos = Games::2048::AI::AlphaBeta::Position->new(dclone $self);
    my $game = Games::AlphaBeta->new($pos, debug => 0);

    $game->ply($self->get_ply);
    my $abmove = $game->abmove;
    my $move = $game->peek_move;
    $self->move([$move->[0], $move->[1]]);
}

sub get_ply {
    my $self = shift;

    my $available = $self->available_cells;

    return 4  if $available < 2;
    return 3;
}

# disable vector input from the user
sub handle_input_key_vector {}

sub handle_finish {
	my ($self, $app) = @_;

    $self->played($self->played+1);
    if ( $self->played < $self->max_plays ) {
        $app->restart;
    }
    else {
        $app->quit;
    }
}

1;
