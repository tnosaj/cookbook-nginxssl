module Rtnginx
  module Ssl
    module Helper
    include Chef::Mixin::ShellOut
      def enable(site)
        #
        # Symlink and notify service
        #
      end
      def disable(site)
        #
        # Unlink and notify service
        #
      end
    end
  end
end

private

def ASDF
end

