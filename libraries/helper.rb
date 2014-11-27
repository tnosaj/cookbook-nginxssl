module Rtnginx
  module Ssl
    module Helper
    include Chef::Mixin::ShellOut
      def enable(site)
        Chef::Log.info "JAT - enable: "+site
        #
        # Symlink and notify service
        #
        return true
      end
      def disable(site)
        Chef::Log.info "JAT - disable: "+site
        #
        # Unlink and notify service
        #
        return true
      end
    end
    module StringHelper
    include Chef::Mixin::ShellOut
      def parseOptions(opts)
        rv = []
        case opts
        when Array
          rv.push(opts.map { |opt| opt }.join(" "))
        when Hash
          opts.each do |k,v|
            Chef::Log.error " JASON: K -  #{k.to_s}"
            newv = parseOptions(v)
            Chef::Log.error " JASON: newv -  #{newv.to_s}"
            case newv
            when Array
              rv.push(k+" "+newv.map { |opt| opt }.join(" "))
            when String
              rv.push(k+" "+newv)
            end
            Chef::Log.error " JASON: ARRAY:  -  #{rv.to_s}"
          end
        when String
          rv.push(opts)
        else
          raise ArgumentError, "NOT SUPPORTED TYPE FOR: #{opts}"
        end
        Chef::Log.error " JASON: RV -  #{rv.to_s}"
        return rv
      end

      def mergeOptions(defaultopts,nodeopts,resourceopts)
        rv=defaultopts
        if !nodeopts.nil?
          rv.merge!(nodeopts)
        end
        if !resourceopts.nil?
          rv.merge!(resourceopts)
        end
        Chef::Log.info " JAT - new rv = #{rv.to_s}"
        return rv
      end
    end
  end
end

private

def ASDF
end

