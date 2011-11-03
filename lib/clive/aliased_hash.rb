# @example
#   
#   h = AliasedHash.new
#   h[:verbose] = true
#   h.alias(:v, :verbose)
#   
#   h[:v] == h[:verbose]
#   #=> true
#
#   h.to_h
#   #=> {:verbose => true, :v => true}
#
#   h.to_h(true) # without aliases
#   #=> {:verbose => true}
#
class AliasedHash
  
end