module Nginx
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
            case v
            when Array
              rv.push(k+" "+v.map { |opt| opt }.join(" "))
            when Hash
              v.each do |kk,vv|
                rv.push(k+" "+kk+" "+vv.to_s)
              end
            when String
              rv.push(k+" "+v)
            end
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

