class Pawn < Piece
  
  def liberties
    [ [0, advance_dir] ] # diagonal and double-advance are SpecialCase
  end
end