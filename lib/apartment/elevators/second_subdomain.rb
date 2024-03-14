# frozen_string_literal: true

require 'apartment/elevators/subdomain'

module Apartment
  module Elevators
    # Provides a rack based tenant switching solution based on the first subdomain
    # of a given domain name.
    # eg:
    #     - example1.domain.com               => domain
    #     - example2.something.domain.com     => something
    class SecondSubdomain < Subdomain
      def subdomain(host)
        subdomains(host).second
      end
    end
  end
end
