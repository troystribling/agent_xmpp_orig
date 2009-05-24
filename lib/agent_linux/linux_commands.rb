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
    def active_users
      users =`who`.split("\n").collect do |user|
        user_data = user.strip.split(/\s+/)
        ip = /\((.*)\)/.match(user_data.last).captures.last
        active_since = user_data[2] + ' ' + user_data[3]
        {:user => user_data[0], :active_since => active_since, :from_ip => ip}
      end || []
      users.count.eql?(1) ? users.first : users
    end

    #.........................................................................................................
    def processes_using_most_memory
      procs = `ps -eo pid,pcpu,pmem,comm`.split("\n").collect do |p|
          {:pid => p[0], :command => p[3], :cpu => p[1].to_f, :memory => p[2].to_f}
        end
        largest_items_by_attribute(procs, :memory)
    end

    #.........................................................................................................
    def processes_using_most_cpu
      procs = `ps -eo pid,pcpu,pmem,comm`.split("\n").collect do |p|
        {:pid => p[0], :command => p[3], :cpu => p[1].to_f, :memory => p[2].to_f}
      end
      largest_items_by_attribute(procs, :cpu)
    end

    #.........................................................................................................
    def largest_open_files
      files = `lsof  -S 2 +D / | grep -E ' [0-9]+[wru] +REG' `.split("\n").collect do |file|
        {:command => file[0], :file => file[8], :size => file[6].to_f/1024**2}
      end
      largest_items_by_attribute(files, :size)
    end

    #.........................................................................................................
    def largest_files
      files = `ls --color=never /`.split("\n").inject([]) do |result, file|
        unless file.eql?("/proc") or file.eql?("/sys")
          du_result = `du -k /#{file}`.split("\n").collect do |f| 
            fs = file.split(/\s+/)
            result.push({:file => fs[1], :size => fs[0].to_f/1024})
          end
        end
        result
      end
      largest_items_by_attribute(files, :size)
    end
    
    #.........................................................................................................
    def listening_tcp_sockets
      servs = services
      `netstat -ntl`.split("\n").collect do |sock|
        sock_data = sock.strip.split(/\s+/)
        port = sock_data[3].split(":").last
        {:port => port, :service => servs[port][:service] || "unknown"}
      end
    end

    #.........................................................................................................
    def connected_tcp_sockets
      servs = services
      `netstat -nt`.split("\n").collect do |sock|
        sock_data = sock.strip.split(/\s+/)
        local_port = sock_data[3].split(":").last
        remote_ip = sock_data[4].split(":")
        {:local => sock_data[3], :remote => sock_data[4], 
          :service => servs[local_port][:service] || servs[remote_ip.last][:service] || "unknown"}
      end
    end

    #.........................................................................................................
    def udp_sockets
      servs = services
      `netstat -nul`.split("\n").collect do |sock|
        sock_data = sock.strip.split(/\s+/)
        port = sock_data[3].split(":").last
        {:port => port, :service => servs[port][:service] || "unknown"}
      end
    end

  ####........................................................................................................
  private

    #.........................................................................................................
    def largest_items_by_attribute(items, by_attr)
      largest_items = files.sort {|i1, i2| i1[by_attr] <=> i2[by_attr]}
      largest_items = largest_items[0..9] if largest_items.count > 10
      largest_items.count.eql?(1) ? largest_items.first : largest_items
    end

    #.........................................................................................................
    def services
      `cat /etc/services`.split("\n").strip.inject({}) do |result, serv|
        unless /^#/.match(serv) or serv.eql?("")
          serv_data = serv.split(/\s+/)
          pp = serv_data[1].split("/")
          result[pp[1]] = {:service => serv_data[0], :port => pp[0], :protocol => pp[1]}
        end
        result
      end
    end
                   
  ###------------------------------------------------------------------------------------------------------
  end
         
############################################################################################################
# LinuxCommands
end
