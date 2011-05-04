module BrighterPlanet
  class Deploy
    class EmissionEstimateService
      include ::Singleton
      include ReadsFromPublicUrl
      
      def endpoint
        'http://carbon.brighterplanet.com'
      end

      def name
        'EmissionEstimateService'
      end
            
      def method_missing(method_id, *args)
        if args.length == 0 and not block_given?
          from_public_url method_id
        else
          super
        end
      end
    end
  end
end
