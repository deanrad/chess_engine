# vector functionality is mixed into Array, rather than subclassed, to preserve the 
# literal array construction syntax
class Array
  alias :rank :last
  alias :file :first
  
  def walk_from pos, limit
    (0..limit).each do |dist| 
      yield pos ^ self.map{ |dir| dir*dist }
    end
  end
  def diagonal?
    none?{ |dir| dir==0 }
  end
  def ^ other
    [ self[0] + other[0], self[1] + other[1] ]
  end
  def % other
    [ self[0] - other[0], self[1] - other[1] ]
  end
end