##############################################################################################################
module AgentXmpp  
  module XMPP4R
    module Patches
      module XData
    
        ####----------------------------------------------------------------------------------------------------
        module InstanceMethods

          #.....................................................................................................
          def <<(child)
            self.add(child)
          end

          #.....................................................................................................
          def add_field_with_value(var, value)
            field = Jabber::Dataforms::XDataField.new(var)
            field.value = value
            self << field
          end
      
        #### InstanceMethods
        end   
       
      ##### XData
      end
    #### Patches
    end
  ##### XMPP4R
  end
#### AgentXmpp
end

##############################################################################################################
module AgentXmpp  
  module XMPP4R
    module Patches
      module XDataReported
    
          ####----------------------------------------------------------------------------------------------------
          module InstanceMethods

            #.....................................................................................................
            def fields(including_hidden=false)
              fields = []
              each_element do |xe|
                if xe.kind_of?(Jabber::Dataforms::XDataField) and (including_hidden or (xe.type != :hidden and xe.type != :fixed))
                  fields << xe
                end
              end
              fields
            end

            #.....................................................................................................
            def <<(child)
              self.add(child)
            end
      
            #.....................................................................................................
            def add_field(var)
              self << Jabber::Dataforms::XDataField.new(var)
            end
      
        #### InstanceMethods
        end  
        
      ##### XDataReported
      end
    #### Patches
    end
  ##### XMPP4R
  end
#### AgentXmpp
end

##############################################################################################################
Jabber::Dataforms::XData.send(:include, AgentXmpp::XMPP4R::Patches::XData::InstanceMethods)
Jabber::Dataforms::XDataReported.send(:include, AgentXmpp::XMPP4R::Patches::XDataReported::InstanceMethods)

##############################################################################################################
##############################################################################################################
module Jabber
  module Dataforms
    class XDataItem < XMPPElement

      #.....................................................................................................
      name_xmlns 'item', 'jabber:x:data'
    
      #.....................................................................................................
      def fields(including_hidden=false)
        fields = []
        each_element do |xe|
          if xe.kind_of?(Jabber::Dataforms::XDataField) and (including_hidden or (xe.type != :hidden and xe.type != :fixed))
            fields << xe
          end
        end
        fields
      end
    
      #.....................................................................................................
      def <<(child)
        self.add(child)
      end
    
      #.....................................................................................................
      def add_field_with_value(var, value)
        field = Jabber::Dataforms::XDataField.new(var)
        field.value = value
        self << field
      end
          
    #### XDataItem
    end 
  #### Dataforms
  end
#### Jabber
end
