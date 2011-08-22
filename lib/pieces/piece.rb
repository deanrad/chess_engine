class Piece
  attr_accessor :side, :role, :discriminator

  def initialize opts = {:side => :white}
    self.side = opts[:side] 
    self.role = opts[:role] || self.class.name.downcase.to_sym
    self.discriminator = opts[:discriminator]
  end
  
  def advance_dir
    side == :black ? -1 : 1
  end
  def home_rank; side == :white ? 0 : 7 ;end
  
  def hop_limit; 0; end #overridden by LinearPiece
  
  def flank
    if [:king, :queen].include?( @discriminator )
      @discriminator
    else
      nil
    end
  end
  
  def possibilities board, pos=board.index(self)
    liberties.each do |line|
      catch(:line_exhausted) do
        line.walk_from(pos ^ line, hop_limit) do |newpos|
          throw(:line_exhausted) unless Board.valid?(newpos)
          collision = board[newpos]
          if collision.nil?
            yield newpos
          else
            yield newpos if collision.side!=self.side
            throw(:line_exhausted)
          end
        end
      end
    end
  end
  
  def moves board, special_cases = SpecialCases::MODERN_CHESS
    myloc = board.index(self)
    possibles = [].tap do |moves|
      self.possibilities(board, myloc) do |p|
        moves << p
      end
    end
    special_cases.select{ |sc| sc.applies_to?(self.role) }.each do |sc|
      possibles.reject! do |mv|
        sc.forbidden.call(board, self, mv)
      end
      possibles += sc.additional.call(board, self)
    end
    possibles
  end
end

class Symbol
  def opposite
    return :black if self == :white
    return :white if self == :black
  end
end