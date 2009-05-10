############################################################################################################
class LinuxCommands

  ###------------------------------------------------------------------------------------------------------
  class << self
    
    #.........................................................................................................
    def uptime
      result = `uptime`.gsub(/days,/, 'days').split(/,/)
      time_stamp = result[0].split('up')
      users = /(\d+)/.match(result[1]).to_a.last
      load_average = /(\d+\.\d+)/.match(result[2]).to_a.last + ", #{result[3]}, #{result[4]}"
      {:current_time => time_stamp[0].strip, :uptime => time_stamp[1].strip, :active_users => users.strip, :load_average => load_average.strip}
    end

    #.........................................................................................................
    def file_system_usage
      fs_type_result = `df -T`
      fsystem = ['hfs', 'ext3', 'ext', 'ext2'].select{|fst| /\s#{fst}\s/.match(fs_type_result)}.inject([]) do |result, fst|
        `df --type=#{fst} -H`.split("\n")[1..-1].each do |row|
          vals = row.split(/\s+/)
          result.push({:mount => vals[5..-1].join(" "), :size => vals[1], :used => vals[4]})
        end
        result
      end
      # TODO: not sure what is going on single element arrays are packed into another array while multielement arrays
      #       are not. it was screwing up construction of xmpp message
      fsystem.count.eql?(1) ? fsystem.first : fsystem
    end

    #.........................................................................................................
    def ethernet_interfaces
      ifaces = /(eth\d)/.match(`ifconfig -a`).captures.inject([]) do |result, iface|
        ifconfig = `ifconfig #{iface}`
        ip = /inet\saddr:(\d+\.\d+\.\d+\.\d+)/.match(ifconfig).captures.last
        mac = /HWaddr\s(\w+\:\w+\:\w+\:\w+\:\w+\:\w+)/.match(ifconfig).captures.last
        ip.nil? ? result : result.push({:iface => iface, :ip => ip, :mac => mac})  
      end
      ifaces.count.eql?(1) ? ifaces.first : ifaces
    end

  ####.....................................................................................................
  private
                 
  ###------------------------------------------------------------------------------------------------------
  end
         
############################################################################################################
# LinuxCommands
end
