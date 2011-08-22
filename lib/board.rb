# A board is an instant in game time, with complete non-timing related information
class Board < Hash
  WIDTH, HEIGHT = 8, 8

  # See FEN for a description of why these are properties of a board
  attr_accessor :side_to_move
  attr_accessor :lost_white_king_side_castle, :lost_white_queen_side_castle
  attr_accessor :lost_black_king_side_castle, :lost_black_queen_side_castle
  attr_accessor :en_passant_square

  attr_accessor :side_in_check
  
  def self.valid? pos
    pos.all?{ |dir| (0..WIDTH-1).include?(dir) }
  end

  # Uses [2,2] as actual indices, but sugar allows both board[ [2,2] ] or board[2, 2] 
  def [] idx1, idx2=nil
    idx = Array===idx1 ? idx1 : [idx1, idx2]
    super(idx)
  end

  # Uses [2,2] as actual indices, but sugar allows both board[ [2,2] ] or board[2, 2] 
  def []= *args
    idx, obj = args.length==3 ? [ [args[0], args[1]], args[2] ] : [args[0], args[1]]
    super(idx, obj)
  end
  
  def positions_controlled_by side=:white
    values.select{|p| p.side == side }.inject([]) do |positions, piece|
      positions += piece.moves(self)
    end.uniq
  end
  
  def move from_coord, to_coord, special_cases = SpecialCases::MODERN_CHESS
    mover = self[from_coord]
    allowed = mover.moves(self)
    if playable_move = allowed.detect{|m| m==to_coord }
      newboard = self.next
      newboard[to_coord] = newboard.delete(from_coord)

      # Play any global side effects
      special_cases.select{ |sc| sc.applies_to?(mover.role) }.each do |sc|
        sc.side_effect[newboard, mover, from_coord]
      end

      # Play any singleton side_effects 
      if playable_move.respond_to?(:side_effect)
        playable_move.side_effect(newboard, mover)
      end
      
    else
      raise "#{from_coord.inspect} to #{to_coord.inspect} is not an allowed move on this board."
    end
    newboard
  end
  
  def next
    b = self.dup
    b.en_passant_square = nil 
    b
  end
  
  def to_s( for_black = false )
    output = '' # ' ' * (8 * 8 * 2) #spaces or newlines after each 
    ranks  = [7, 6, 5, 4, 3, 2, 1, 0]
    files  = [0, 1, 2, 3, 4, 5, 6, 7]
    (ranks.reverse! and files.reverse!) if for_black
    last_file = files.last
    ranks.each do |rank|
      files.each do |file|
        piece = self[ file, rank ]
        output << (piece ? piece.class.name[0..0] : ' ')
        output << (file != last_file ? ' ' : "\n")
      end
    end  
    output + "\n"
  end
  
  def inspect; to_s; end
  
end