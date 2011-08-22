class Bishop < LinearPiece
  def liberties; [ [1,1], [-1,1], [1,-1], [-1,-1] ] ;end
end