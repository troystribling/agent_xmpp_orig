############################################################################################################
class LinuxCommands

  ###------------------------------------------------------------------------------------------------------
  class << self
    
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

    #.........................................................................................................
    def who
      users =`who`.split("\n").inject([]) do |result, user|
        user_data = user.strip.split(/\s+/)
        ip = /\((.*)\)/.match(user_data.last).captures.last
        active_since = user_data[2] + ' ' + user_data[3]
        result.push({:user => user_data[0], :active_since => active_since, :from_ip => ip})
      end
      users.count.eql?(1) ? users.first : users
    end
    
  ####.....................................................................................................
  private
                 
  ###------------------------------------------------------------------------------------------------------
  end
         
############################################################################################################
# LinuxCommands
end
