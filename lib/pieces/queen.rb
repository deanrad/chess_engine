class Queen < LinearPiece
  def liberties; Rook.new.liberties + Bishop.new.liberties ;end
end