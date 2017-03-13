use strict;
use warnings;


package Reversi;
sub new {
	my $class = shift;
	my $board = [
		['.', '.', '.', '.', '.', '.', '.', '.'],
		['.', '.', '.', '.', '.', '.', '.', '.'],
		['.', '.', '.', '.', '.', '.', '.', '.'],
		['.', '.', '.', 'O', 'X', '.', '.', '.'],
		['.', '.', '.', 'X', 'O', '.', '.', '.'],
		['.', '.', '.', '.', '.', '.', '.', '.'],
		['.', '.', '.', '.', '.', '.', '.', '.'],
		['.', '.', '.', '.', '.', '.', '.', '.'],
	];
	my $black = 0;
	my $white = 0;
	my $gameEnd = 0;
	my $pass = 0;
	my $playerX;
	my $playerO;
	my $turn;

	print "First player is (1) Computer or (2) Human? ";
	my $firstPlayer = <>;
	if ($firstPlayer == 1) {
		print "Player X is Computer\n";
		$playerX = Computer->new('X', $board);
	} elsif ($firstPlayer == 2) {
		print "Player X is Human\n";
		$playerX = Human->new('X', $board);
	}

	print "Second player is (1) Computer or (2) Human? ";
	my $secondPlayer = <>;
	if ($secondPlayer == 1) {
		print "Player O is Computer\n";
		$playerO = Computer->new('O', $board);
	} elsif ($secondPlayer == 2) {
		print "Player O is Human\n";
		$playerO = Human->new('O', $board);
	}

	my $self = {
		black => $black,
		white => $white,
		turn => $turn = $playerX,
		gameEnd => $gameEnd,
		pass => $pass,
		playerX => $playerX,
		playerO => $playerO,
		board => $board
	};

	return bless $self, $class;

}

sub startGame {
	my $self = shift;
	my $gameEnd = $self->{gameEnd};
	my $playerX = $self->{playerX};
	my $playerO = $self->{playerO};
	my $board = $self->{board};
	my $numflipped;
	my @position;
	my $symbol;

	while ($gameEnd == 0) {
		$self->{black} = 0;
		$self->{white} = 0;

		for(my $row = 0; $row < 8; $row++) {
	    	for(my $col = 0; $col < 8; $col++) {
	    		if ($board->[$row][$col] eq 'X') {
	    			$self->{black}++;
	    		} elsif ($board->[$row][$col] eq 'O') {
	    			$self->{white}++;
	    		}
   			}
		}

		my $full = $self->{black} + $self->{white};

		$self->printBoard;

		# check winner...
		if ($self->{pass} == 2 || $full == 64) {
			$gameEnd = $self->checkWinner;
		} 

		if ($gameEnd == 0) {
			$symbol = $self->{turn}->getSymbol;
			@position = $self->{turn}->nextMove;
			$self->checkValidMove(@position);
		
			# change player...
			if ($symbol eq 'X') {
				$self->{turn} = $playerO;
			} else {
				$self->{turn} = $playerX;
			}
		}

	}

}

sub printBoard {
	my $self = shift;
	my $black = $self->{black};
	my $white = $self->{white};
	my $board = $self->{board};
	# printing the board....
	print "  0 1 2 3 4 5 6 7\n";
	for(my $row = 0; $row < 8; $row++) {
		print "$row ";
    	for(my $col = 0; $col < 8; $col++) {
        	print "$board->[$row][$col] ";
   		}
   		print "\n";
	}
	print "Player X: $black\n";
	print "Player O: $white\n";
}

sub checkValidMove {
	my $self = shift;
	my $board = $self->{board};
	my $turn = $self->{turn};
	my $symbol = $turn->getSymbol;
	my @position = @_;
	my $tempx;
	my $tempy;
	my $numflipped = 0;

	# check out of range...
	chomp @position;

	if ($position[0] < 0 || $position[0] > 7 || $position[1] < 0 || $position[1] > 7) {
		print "Row $position[0], col $position[1] is invalid! Player $symbol passed!\n";	
		$self->{pass}++;
		return $numflipped;
	}
	#check empty...
	if ($board->[$position[0]][$position[1]] ne '.') {
		print "Row $position[0], col $position[1] is invalid! Player $symbol passed!\n";
		$self->{pass}++;
		return $numflipped;
	}

	$numflipped += $self->scanBoard(\@position, "up");
	$numflipped += $self->scanBoard(\@position, "down");
	$numflipped += $self->scanBoard(\@position, "left");
	$numflipped += $self->scanBoard(\@position, "right");
	$numflipped += $self->scanBoard(\@position, "top-left");
	$numflipped += $self->scanBoard(\@position, "top-right");
	$numflipped += $self->scanBoard(\@position, "bottom-left");
	$numflipped += $self->scanBoard(\@position, "bottom-right");

	if ($numflipped == 0) {
		print "Row $position[0], col $position[1] is invalid! Player $symbol passed!\n";
		$self->{pass}++;
	} else {
		print "Player $symbol places to row $position[0], col $position[1]\n";
		$self->{pass} = 0;
	}

	return $numflipped;

}
sub scanBoard {
	my $self = shift;
	my ($position, $direction) = @_;
	my @position = @{$position};
	my $board = $self->{board};
	my $turn = $self->{turn};
	my $symbol = $turn->getSymbol;
	my $delta_x;
	my $delta_y;
	my $tempx;
	my $tempy;
	my $numflipped;

	if ($direction eq "up") {
		$delta_x = -1; $delta_y = 0;
	} elsif ($direction eq "down") {
		$delta_x = 1; $delta_y = 0;
	} elsif ($direction eq "left") {
		$delta_x = 0; $delta_y = -1;
	} elsif ($direction eq "right") {
		$delta_x = 0; $delta_y = 1;
	} elsif ($direction eq "top-left") {
		$delta_x = -1; $delta_y = -1;
	} elsif ($direction eq "top-right") {
		$delta_x = -1; $delta_y = 1;
	} elsif ($direction eq "bottom-left") {
		$delta_x = 1; $delta_y = -1;
	} elsif ($direction eq "bottom-right") {
		$delta_x = 1; $delta_y = 1;
	}

	$tempx = $position[0]; $tempy = $position[1];
	$numflipped = 0;

	while (1) {
		$tempx += $delta_x; $tempy += $delta_y;
		if ($tempx < 0 || $tempx > 7 || $tempy < 0 || $tempy > 7) { 
			$numflipped = 0;
			return $numflipped;
		}
		if ($board->[$tempx][$tempy] eq '.') {
			$numflipped = 0; 
			return $numflipped;
		} elsif ($board->[$tempx][$tempy] ne '.' && $board->[$tempx][$tempy] ne $symbol) {
			$numflipped++;
		} elsif ($board->[$tempx][$tempy] eq $symbol) {
			if ($numflipped == 0) { 
				return $numflipped;
			} else {
				$self->flipPieces(\@position, $direction, $numflipped);
				return $numflipped;
			}
		}
	}

}

sub flipPieces {
	my $self = shift;
	my ($position, $direction, $numflipped) = @_;
	my @position = @{$position};
	my $board = $self->{board};
	my $turn = $self->{turn};
	my $symbol = $turn->getSymbol;
	my $delta_x;
	my $delta_y;
	my $tempx;
	my $tempy;


	if ($direction eq "up") {
		$delta_x = -1; $delta_y = 0;
	} elsif ($direction eq "down") {
		$delta_x = 1; $delta_y = 0;
	} elsif ($direction eq "left") {
		$delta_x = 0; $delta_y = -1;
	} elsif ($direction eq "right") {
		$delta_x = 0; $delta_y = 1;
	} elsif ($direction eq "top-left") {
		$delta_x = -1; $delta_y = -1;
	} elsif ($direction eq "top-right") {
		$delta_x = -1; $delta_y = 1;
	} elsif ($direction eq "bottom-left") {
		$delta_x = 1; $delta_y = -1;
	} elsif ($direction eq "bottom-right") {
		$delta_x = 1; $delta_y = 1;
	}

	$board->[$position[0]][$position[1]] = $symbol;
	$tempx = $position[0]; $tempy = $position[1];

	for (my $i = 0; $i < $numflipped; $i++) {
		$tempx += $delta_x; $tempy += $delta_y;
		$board->[$tempx][$tempy] = $symbol;
	}



}
sub checkWinner {
	my $self = shift;
	my $black = $self->{black};
	my $white = $self->{white};

	if ($black > $white) {
		print "Player X wins!\n";
		return 1;
	} elsif ($black < $white) {
		print "Player O wins!\n";
		return 1;
	} elsif ($black == $white) {
		print "Draw game!\n";
		return 1;
	}
}


package Player;
sub new {
	my $class = shift;
	my ($symbol, $board) = @_;
	my $self = {
		sym => $symbol,
		board => $board,
	};
	return bless $self, $class;
}

sub nextMove {
	# body...
}

sub getSymbol {
	my $self = shift;
	return $self->{sym};
}


package Human;
use base qw ( Player );
# overriding...
sub nextMove {
	my $self = shift;
	my $input;
	my @position;
	my $symbol = $self->{sym};
	print "Player $symbol, make a move (row col): ";
	$input = <>;
	@position = split(/ /, $input);
	return @position;
}

package Computer;
use Data::Dumper;

use base qw ( Player );
# overriding...ver 1
sub nextMove {
	my $self = shift;
	my @position;
	my $symbol = $self->{sym};

	@position = $self->obtainValidMove;
	if ($position[0] == -1 && $position[1] == -1) {
		print "Player $symbol places to row $position[0], col $position[1]\n";
	}

	return @position;
}

sub obtainValidMove{
	my $self = shift;
	my $board = $self->{board};
	my $numflipped;
	my @validMove;
	my @choice;
	my @invalid = (-1, -1);
	for(my $row = 0; $row < 8; $row++) {
	   	for(my $col = 0; $col < 8; $col++) {
	   		$numflipped = 0;
	    	if ($board->[$row][$col] eq '.') {
	    		$numflipped += $self->AIscanBoard($row, $col, "up");
				$numflipped += $self->AIscanBoard($row, $col, "down");
				$numflipped += $self->AIscanBoard($row, $col, "left");
				$numflipped += $self->AIscanBoard($row, $col, "right");
				$numflipped += $self->AIscanBoard($row, $col, "top-left");
				$numflipped += $self->AIscanBoard($row, $col, "top-right");
				$numflipped += $self->AIscanBoard($row, $col, "bottom-left");
				$numflipped += $self->AIscanBoard($row, $col, "bottom-right");
				if ($numflipped != 0) {
					push (@validMove, [$row, $col]);
				}
	    	}
   		}
	}

	my $size = @validMove;
	if ($size == 0) {
		return @invalid;
	}
	my $random = int rand($size);
	$choice[0] = $validMove[$random][0];
	$choice[1] = $validMove[$random][1];
	return @choice;
}

sub AIscanBoard {
	my $self = shift;
	my ($row, $col, $direction) = @_;
	my $board = $self->{board};
	my $symbol = $self->{sym};
	my $delta_x;
	my $delta_y;
	my $tempx;
	my $tempy;
	my $numflipped;

	if ($direction eq "up") {
		$delta_x = -1; $delta_y = 0;
	} elsif ($direction eq "down") {
		$delta_x = 1; $delta_y = 0;
	} elsif ($direction eq "left") {
		$delta_x = 0; $delta_y = -1;
	} elsif ($direction eq "right") {
		$delta_x = 0; $delta_y = 1;
	} elsif ($direction eq "top-left") {
		$delta_x = -1; $delta_y = -1;
	} elsif ($direction eq "top-right") {
		$delta_x = -1; $delta_y = 1;
	} elsif ($direction eq "bottom-left") {
		$delta_x = 1; $delta_y = -1;
	} elsif ($direction eq "bottom-right") {
		$delta_x = 1; $delta_y = 1;
	}

	$tempx = $row; $tempy = $col;
	$numflipped = 0;

	while (1) {
		$tempx += $delta_x; $tempy += $delta_y;
		if ($tempx < 0 || $tempx > 7 || $tempy < 0 || $tempy > 7) { 
			$numflipped = 0;
			return $numflipped;
		}
		if ($board->[$tempx][$tempy] eq '.') {
			$numflipped = 0; 
			return $numflipped;
		} elsif ($board->[$tempx][$tempy] ne '.' && $board->[$tempx][$tempy] ne $symbol) {
			$numflipped++;
		} elsif ($board->[$tempx][$tempy] eq $symbol) {
			return $numflipped;
		}
	}
}



my $game = Reversi->new(); 	# Create object; set up human/computer players 
$game->startGame; 			# Start playing game
