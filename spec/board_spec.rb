require 'spec_helper'

describe Piece do
  it 'should have a side (black or white)'
  it 'should have a role (rook, pawn, etc)'
  it 'may have a discriminator (kings, a, b, h)'
end

describe Graveyard do
  it 'should have a board'
  it 'should have a side'
  it 'should store pieces'
  it 'should have a point total'
end

describe Coordinate do
  it 'should have a rank, 1-8'
  it 'should have a file, a-h'
end

describe Move do
  it 'should have a from and to coordinate'
  it 'should refer to a board'
  it 'can be notated'
end

describe Board do
  it 'should assign to each position a piece or nil'
  describe 'when indexed by a position' do 
    it 'may return nil'
    describe 'or may return a piece' do 
      it 'should be able to respond with the indices it can move to on that board (allowed_moves)'
      describe 'when special behaviors apply' do
        it 'must include special behaviors additionally allowed moves in its allowed moves'
      end
    end
  end
  
  describe 'can accept a move and return a board on which that move has been played' do
    it 'should reject a move not playable (see move_spec) and return self'
    it 'should track which piece it moves'

    describe 'Non Special moves' do 
      describe 'capturing' do
        it 'should empty the from_coord'
        it 'should place the moved piece onto the to_coord'
        it 'should delete the opposing piece on the to_coord and mark as the catpured_piece'
        it 'should move any captured piece to the movers graveyard'
      end
      describe 'noncapturing' do
        it 'should empty the from_coord'
        it 'should place the moved piece onto the to_coord'
      end
    end
    
    describe 'Moves affected by special cases' do 
      it 'should play any side_effects' do 
      end
    end
  end
end

describe SpecialBehavior do
  describe 'Given board and index' do
    it 'should return indexes of allowed_moves it additionally enables (ala castling, en_passant)'
    it 'should return indexes of moves it forbids (ala leaving self in check)'
  end
  describe 'if used to make the move' do
    it 'may return a corollary move (ala castling) which will then be played'
    it 'may return a corollary capture (ala en passant)'
  end
end

