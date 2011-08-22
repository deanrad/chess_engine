# Anatomy of a SpecialCase
#
#   applicable_role: the piece role (eg knight, pawn, etc..)  this case applies to
#   additional: a lambda taking the board and a matching piece, returning
#               moves this piece has additionaly available to it 
#               (example: a pawn on its home rank has a double advance option)
#   forbidden:  a lambda taking the board, a piece, and a new position, and returning
#               true if this is a forbidden move at this time 
#               (example: a pawn cannot capture forward)
#   side_effect: a lambda taking the board, the moved piece, and a new position
#                and is executed upon that move
#               (example: moving a rook denies castling on that side)
#   user_text: a user-facing description, best for forbidden moves, or side effects
#
# Example: pawn_can_move_diagonally_if_capturing = 
#          SpecialCase.new(
#            :applicable_role => :pawn,  
#            :additional => lambda{ |board, pawn| ... } 
#              curpos = board.index(pawn)
#              additional = []
#              [ [-1, pawn.advance_dir], [1, pawn.advance_dir] ].each do |m|
#                if( collision= board[curpos ^ m] )
#                  additional << (curpos^m) if collision.side != pawn.side
#                end
#              end
#              additional
#            })
#          end

class SpecialCase
  attr_accessor :applicable_role, :forbidden, :additional, :side_effect, :friendly_name
  
  def initialize opts
    self.applicable_role = opts[:applicable_role]
    self.friendly_name = opts[:friendly_name] 
    self.forbidden   = opts[:forbidden]   || lambda{ |b, p, np|  false }
    self.additional  = opts[:additional]  || lambda{ |b, p|      [] }
    self.side_effect = opts[:side_effect] || lambda{ |nb, p, op| ; }
  end
  
  def applies_to? role; applicable_role == role; end
end