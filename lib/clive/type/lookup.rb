module Clive
  class Type
  
    module Lookup
    
      protected
      
      # Provides access to Types defined under {Type} as if accessed
      # normally.
      #
      # @param name [#to_s] The name of the Type to lookup.
      # @return [Type] The type with the given name.
      # @raise [NameError] The property could not be found.
      #
      def const_missing(name)
        Type.find_class(name.to_s) || super
      end
      
    end
  end
end