require "../cluster"

module Cavorite::Remote
  class K8sCluster < Cluster
    def initialize(@service : String, @namespace : String = "default")
      super(@namespace)
    end

    def ip_address_list
      domain = "#{@service}.#{@namespace}.svc.cluster.local"
      Socket::Addrinfo.resolve(domain, 53, type: Socket::Type::STREAM)
        .map { |addrinfo| addrinfo.ip_address.address }
    end
  end
end
