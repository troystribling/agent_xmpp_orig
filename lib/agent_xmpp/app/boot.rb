require 'find'

##############################################################################################################
module AgentXmpp

  #####-------------------------------------------------------------------------------------------------------
  class Boot
    
    ####......................................................................................................
    class << self

      #.......................................................................................................
      def app_dir
        Dir.pwd
      end
      
      #.......................................................................................................
      def before_config_load(&blk)
         define_meta_class_method(:call_before_config_load, &blk)
      end

      #.......................................................................................................
      def after_connection_completed(&blk)
         define_meta_class_method(:call_after_connection_completed, &blk)
      end

      #.......................................................................................................
      def before_app_load(&blk)
         define_meta_class_method(:call_before_app_load, &blk)
      end

      #.......................................................................................................
      def after_app_load(&blk)
         define_meta_class_method(:call_after_app_load, &blk)
      end
    
      ####------------------------------------------------------------------------------------------------------
      def load(path, options = {})
        exclude_files = options[:exclude] || []
        Find.find(path) do |file_path|
          if file_match = /(.*)\.rb$/.match(file_path)
            file = file_match.captures.last
            require file unless exclude_files.include?(file)
          end
        end
      end
    
    end
    ####......................................................................................................

  #### Boot
  end
  
#### AgentXmpp
end
