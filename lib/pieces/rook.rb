class Rook < LinearPiece
  def liberties; [ [1,0], [-1,0], [0,-1], [0,1] ] ;end
end