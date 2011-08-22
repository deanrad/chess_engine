class Knight < Piece
  def liberties; [[1,2], [1,-2], [2,1], [2,-1], [-1,2], [-1,-2], [-2,1], [-2,-1]]; end
end