class SpecialCases
  class << self
    def pawn_cannot_capture_forward
      SpecialCase.new(
        :user_text => "A pawn cannot capture in the forward direction, only diagonally.",
        :applicable_role => :pawn,
        :forbidden => lambda{ |board, pawn, newpos| 
          curpos = board.index(pawn)
          vector = newpos % curpos
          if vector.first == 0 && vector.last == pawn.advance_dir
            return true unless board[newpos].nil?
          end
        })
    end
    
    def pawn_can_move_diagonally_if_capturing
      SpecialCase.new(
        :applicable_role => :pawn,
        :additional => lambda{ |board, pawn|
          curpos = board.index(pawn)
          additional = []
          [ [-1, pawn.advance_dir], [1, pawn.advance_dir] ].each do |m|
            if( collision= board[curpos ^ m] )
              additional << (curpos^m) if collision.side != pawn.side
            end
          end
          additional
        })
    end
    
    def pawn_can_double_advance_on_its_first_move
      SpecialCase.new(
        :user_text => "On its first move, a pawn may advance 2 spaces if unobstructed.",
        :applicable_role => :pawn,
        :additional => lambda{ |board, pawn| 
          curpos = board.index(pawn)
          homerank = pawn.side == :black ? 6 : 1
          if curpos.rank == homerank
            newpos  = curpos ^ [0, 2*pawn.advance_dir]
            skipped = curpos ^ [0, 1*pawn.advance_dir]
            (board[newpos].nil? && board[skipped].nil?) ? [newpos] : []
          end })
    end

    def moving_a_pawn_two_squares_opens_up_en_passant
      SpecialCase.new(
        :user_text => "A doubly-moved pawn can still be captured as though it only moved one square."
        :applicable_role => :pawn,
        :side_effect => lambda{ |newboard, pawn, oldpos|
          was_double = (newboard.index(pawn) % oldpos ).last.abs == 2
          newboard.en_passant_square = oldpos ^ [0, pawn.advance_dir] if was_double
        })
    end
    
    def moving_a_rook_forfeits_that_flanks_castling
      SpecialCase.new(
        :user_text => "Because that rook was moved, you can no longer castle on that side.",
        :applicable_role => :rook,
        :side_effect => lambda{ |newboard, rook, oldpos|
          newboard.send( "lost_#{rook.side}_#{rook.flank}_side_castle=", true )
        })
    end

    def moving_the_king_forfeits_castling
      SpecialCase.new(
        :user_text => "Castling is no longer allowed once the king is moved.",
        :applicable_role => :king,
        :side_effect => lambda{ |newboard, king, oldpos|
          newboard.send( "lost_#{king.side}_king_side_castle=", true )
          newboard.send( "lost_#{king.side}_queen_side_castle=", true )
        })
    end
    
    def king_may_have_castling_squares_available
      SpecialCase.new(
        :applicable_role => :king,
        :additional => lambda{ |b, king|
          additional = []
          opponent_controlled = b.positions_controlled_by( king.side.opposite )
          [ [:king, [5,6]], [:queen, [1,2,3]] ].each do | flank, interposers |

            clear_to_move = interposers.inject(true) do |clear, file| 
              clear &&= b[ [file, king.home_rank] ].nil?
            end

            already_attacked = opponent_controlled.include?( [4, king.home_rank])
            
            moves_through_or_into_attack = interposers.inject(false) do |attack, file|
              attack ||= opponent_controlled.include?( [file, king.home_rank] )
            end
            
            if b.send( "lost_#{king.side}_#{flank}_side_castle" ) != true 
              if clear_to_move && !already_attacked && !moves_through_or_into_attack
                newpos = [ flank==:queen ? 1 : 6, king.home_rank]
                
                def newpos.side_effect newboard, king, oldpos
                  rook = newboard.delete( [ self.first == 1 ? 0 : 7, king.home_rank] )
                  newboard.store( [self.first == 1 ? 2 : 5, king.home_rank], rook)
                end
                
                additional << newpos
              end
            end
          end
          
          additional
        })
    end
  end

  MODERN_CHESS = [
      self.pawn_cannot_capture_forward,
      self.pawn_can_move_diagonally_if_capturing,
      self.pawn_can_double_advance_on_its_first_move,
      self.moving_a_pawn_two_squares_opens_up_en_passant,
      self.moving_a_rook_forfeits_that_flanks_castling,
      self.moving_the_king_forfeits_castling,
      self.king_may_have_castling_squares_available,
  ]
  
end