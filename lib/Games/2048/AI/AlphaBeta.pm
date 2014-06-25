package Games::2048::AI::AlphaBeta;
use 5.012;
use Moo;
use Games::AlphaBeta;
use Games::2048::AI::AlphaBeta::Position;
use Data::Dumper;

extends 'Games::2048::Game::Input';

use Storable qw/dclone/;

my @vecs = ([-1, 0], [1, 0], [0, -1], [0, 1]);
my @names = qw/left right up down/;

has toggle    => is => 'rw', default => 0;
has toggle_xy => is => 'rw', default => 0;
has lowest    => is => 'rw', default => 0;

sub handle_input {
	my ($self, $app) = @_;

    my $pos = Games::2048::AI::AlphaBeta::Position->new(dclone $self);
    my $game = Games::AlphaBeta->new($pos, debug => 0);

    $game->ply($self->get_ply);
    my $abmove = $game->abmove;
    my $move = $game->peek_move;
    $self->move([$move->[0], $move->[1]]);

#<STDIN>;

	$self->next::method($app);
}

sub get_ply {
    my $self = shift;

return 1;
    my $available = $self->available_cells;

    return 5  if $available < 3;
    return 5  if $available < 6;
    return 4  if $available < 12;
    return 3;
}

sub draw_score {
	my $self = shift;
	$self->score_height(2);

	printf "lowest: %d, toggle: %d, toggle_xy: %d\n",
		$self->lowest, $self->toggle, $self->toggle_xy;

	$self->next::method;
}

# disable vector input from the user
sub handle_input_key_vector {}

1;
