# frozen_string_literal: true

module ActiveStorage::SetBlob # :nodoc:
  if ActiveStorage::VERSION::MAJOR >= 7
    extend ActiveSupport::Concern

    included do
      before_action :set_blob
    end

    private

    def set_blob
      # The hypothesis is that when this is called, a new ActiveRecord connection
      # is getting created, and the apartment gem doesn't know about it, so it is
      # using the default database instead of the proper tenant.
      #
      # Not sure where that is happening, or what we could do about it,
      # but we'll monkey patch this area of the code to do an apartment switch
      # based on the request.
      #
      # The initializer wants an app because this is supposed to be used as
      # a Rack application, but we only need the method to extract the tenant
      # from the request, so we just need a placholder for the app (nil).
      #
      # Note that this depends on the class
      # matching the one we use in config/initializers/apartment.rb.
      if ENV["ENABLE_NEXTJS"]
        tenant = Apartment::Elevators::SecondSubdomain.new(nil).parse_tenant_name(request)
      else
        tenant = Apartment::Elevators::Subdomain.new(nil).parse_tenant_name(request)  
      end
      
      Apartment::Tenant.switch!(tenant)
      @blob = blob_scope.find_signed!(params[:signed_blob_id] || params[:signed_id])

    rescue ActiveSupport::MessageVerifier::InvalidSignature
      head :not_found
    end

    def blob_scope
      ActiveStorage::Blob
    end

  end
end
