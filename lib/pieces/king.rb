class King < Piece
  def liberties; Rook.new.liberties + Bishop.new.liberties ;end
end