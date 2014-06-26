package Games::2048::AI::AlphaBeta::Position;
use v5.12;
use base qw(Games::AlphaBeta::Position);

my @vecs = ([-1, 0], [1, 0], [0, -1], [0, 1]);

sub init {
    my ($self, $game) = @_;
    $self->player(1);
    $self->game($game);
    return $self;
}

sub switch_player {
    my $self = shift;
    if ( $self->{player} == 1 ) {
        $self->player(0);
    }
    else {
        $self->player(1);
    }
}

sub game {
    my $self = shift;
    $self->{game} = shift if @_;
    return $self->{game};
}

# Methods required by Games::AlphaBeta
sub apply {
    my ($self, $m) = @_;

    my $g = dclone $self->game;
    if ( $self->player) {
        $g->move_tiles([$m->[0], $m->[1]]);
    }
    else {
        $g->insert_tile([$m->[0], $m->[1]],$m->[2]);
    }
    $self->game($g);

    $self->switch_player;

    $self;
}

sub findmoves {
    my $self = shift;

    my @m;

    if ( $self->player ) {
        for (0..3) {
            my $g = dclone $self->game;

            my $move = $vecs[$_];
            push (@m, $move) if ($g->move_tiles($move));
        }
    }
    else {
        @m = map { ([$_->[0], $_->[1], 2], [$_->[0], $_->[1], 4]) } $self->game->available_cells;
    }

    @m;
}

sub evaluate {
    my $self = shift;

    my $free = $self->game->available_cells;
    my $max  = $self->_max_value;

    my $s = 0
        + 3       * $max
        + 2       * $self->_in_corner($max)
        + 0.00001 * $self->_growth
        + 3       * ($free ? log($free) : 0 )
        + 0.2     * $self->_smoothness;

    # I prefer this corner
    $s++ if $self->game->_tiles->[0][0];

    return $self->player? $s: -$s;
}

sub _growth {
    my $self = shift;

    my $t = $self->game->_tiles;

    my $s = 0;
    $s += $self->_grows( $t->[0][0], $t->[0][1], $t->[0][2], $t->[0][3] ) * 2;
    $s += $self->_grows( $t->[1][0], $t->[1][1], $t->[1][2], $t->[1][3] );
    $s += $self->_grows( $t->[2][0], $t->[2][1], $t->[2][2], $t->[2][3] );
    $s += $self->_grows( $t->[3][0], $t->[3][1], $t->[3][2], $t->[3][3] ) * 2;

    $s += $self->_grows( $t->[0][0], $t->[1][0], $t->[2][0], $t->[3][0] ) * 2;
    $s += $self->_grows( $t->[0][1], $t->[1][1], $t->[2][1], $t->[3][1] );
    $s += $self->_grows( $t->[0][2], $t->[1][2], $t->[2][2], $t->[3][2] );
    $s += $self->_grows( $t->[0][3], $t->[1][3], $t->[2][3], $t->[3][3] ) * 2;

    $s;
}

sub _grows {
    my $self = shift;

    my @list = @_;
    return 0 unless my @values = map { $_->value }
                                 grep {$_} @_;

    # List of 1 does not grow
    return 0 if @_ == 1;
    my $s = $self->_sorted(@values) || $self->_sorted(reverse @values);
    return $s * @_;
}

sub _sorted {
    my $self = shift;

    my $idx = 0;
    my $last = $_[$idx];
    my $s = $last;

    while ( my $new = $_[$idx++] ) {
        return 0 if ( $new < $last );
        $s += $new * $new;
        $last = $new;
    }

    $s;
}

sub _max_value {
    my $self = shift;

    my $max = 0;

    for my $y (@{$self->game->_tiles}) {
        for my $x (@$y) {
            if ($x) {
                $max = $x->value if $x->value > $max;
            }
        }
    }
    return $max;
}

sub _in_corner {
    my ($self, $max) = @_;

    my $t = $self->game->_tiles;

    return $max if $t->[0][0] && $t->[0][0]->value == $max;
    return $max if $t->[0][3] && $t->[0][3]->value == $max;
    return $max if $t->[3][0] && $t->[3][0]->value == $max;
    return $max if $t->[3][3] && $t->[3][3]->value == $max;

    return 0;
}

sub _smoothness {
    my $self = shift;

    my $t = $self->game->_tiles;

    my $s = 0;
    for my $x ( 0..3 ) {
        for my $y ( 0..3 ) {
            if ( my $cell = $t->[$x][$y] ) {
                my $value = log($cell->value) / log(2);
                for my $vector ( ([1, 0], [0, 1] )) {
                    if ( my $target = $self->find_farthest( $x, $y, $vector) ) {
                        my $target_value = log($target->value) / log(2);
                        $s -= abs($value - $target_value);
                    }
                }
            }
        }
    }
    return $s;
}

sub find_farthest {
    my ($self, $x, $y, $vector) = @_;

    my $cell;

    while ( !$cell && $x <= 3 && $y <= 3 ) {
        $x += $vector->[0];
        $y += $vector->[1];
        $cell = $self->game->_tiles->[$x][$y];
    }

    return $cell;
}

1;

