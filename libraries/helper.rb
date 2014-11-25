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
        case opts
        when Array
          return opts.map { |opt| opt }.join(" ")
        when Hash
          rv = []
          opts.each do |k,v|
            rv.push! (k.merge!(parseOptions(v)))
          end
          return rv.sort!
        when String
          return opts
        else
          Chef::Log.error "NOT SUPPORTED TYPE FOR: #{opts}"
          raise ArgumentError, "NOT SUPPORTED TYPE FOR: #{opts}"
        end 
      end
      def mergeOptions(defaultopts,nodeopts,resourceopts)
        rv=defaultopts
        if !nodeopts.nil?
          rv.merge!(nodeopts)
        end
        if !resourceopts.nil?
          rv.merge!(resourceopts)
        end
        return rv
      end
    end
  end
end

private

def ASDF
end

