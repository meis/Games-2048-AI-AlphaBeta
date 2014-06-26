package Games::2048::AI::AlphaBeta;
use 5.012;
use Moo;
use Games::AlphaBeta;
use Games::2048::AI::AlphaBeta::Position;
extends 'Games::2048::Game::Input';

has moves => is => 'rw', default => 0;
has time  => is => 'rw';

sub handle_input {
	my ($self, $app) = @_;

    my $p = Games::AlphaBeta->new(Games::2048::AI::AlphaBeta::Position->new($self));

    $p->ply(4);
    $p->abmove;
    my $m = $p->peek_move;
    $self->move([$m->[0], $m->[1]]);
}

# disable vector input from the user
sub handle_input_key_vector {}

sub handle_finish { $_[1]->restart }

sub draw_score {
	my $self = shift;

	$self->score_height(2);

    $self->time(time()) unless $self->time;
    my $time = time() - $self->time;

    $self->moves($self->moves+1);
    say "moves: " . $self->moves . " time: " . $time;

	$self->next::method;
}

1;
