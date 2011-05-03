module BrighterPlanet
  class Deploy
    class Server
      include ReadsFromLocalFilesystem
      
      class << self
        def me
          new :local => true
        end
      end
    
      def initialize(attrs = {})
        attrs.each do |k, v|
          if respond_to? "#{k}="
            send "#{k}=", v
          else
            instance_variable_set "@#{k}", v
          end
        end
      end

      def local?
        !!@local
      end
      
      attr_writer :rails_root
      def rails_root
        @rails_root || local_rails_root
      end
      
      attr_writer :hostname
      def hostname
        @hostname || local_hostname
      end
      
      attr_writer :public_dir
      def public_dir
        @public_dir || ::File.join(rails_root, 'public')
      end
      
      attr_writer :private_dir
      def private_dir
        @private_dir || ::File.join(rails_root, 'config')
      end
      
      attr_writer :gender
      def gender
        @gender || lookup(:gender)
      end
      
      attr_writer :phase
      def phase
        @phase || lookup(:phase)
      end
      
      attr_writer :environment
      def environment
        @environment || local_rails_environment
      end
      
      attr_writer :service
      def service
        @service || lookup(:service)
      end
            
      attr_writer :resque_redis_url
      def resque_redis_url
        @resque_redis_url || lookup(:resque_redis_url)
      end
      
      attr_writer :status
      def status
        @status || if gender == service_class.gender
          :active
        else
          :standby
        end
      end
      
      def service_class
        case service
        when :EmissionEstimateService, :cm1
          EmissionEstimateService.instance
        end
      end
      
      PUBLIC = [:gender, :phase, :service]
      PRIVATE = [:resque_redis_url]
      ALWAYS_SYMBOLIZE = [:gender, :phase, :service]
      
      class InvalidKey < ::ArgumentError;
      end
      
      private
      
      def lookup(id)
        id = id.to_sym
        str = if PUBLIC.include? id
          from_public_dir id
        elsif PRIVATE.include? id
          from_private_dir id
        else
          raise InvalidKey, "[brighter_planet_deploy] Unknown key #{id}"
        end
        ALWAYS_SYMBOLIZE.include?(id) ? str.to_sym : str
      end
      
      def local_hostname
        return unless local?
        `hostname -f`.chomp
      end
      
      def local_rails_root
        return unless local?
        if defined?(::Rails) and ::Rails.respond_to?(:root)
          ::Rails.root
        elsif ::ENV.has_key? 'RAILS_ROOT'
          ::ENV['RAILS_ROOT']
        end
      end
      
      def local_rails_environment
        return unless local?
        if defined?(::Rails) and ::Rails.respond_to?(:env)
          ::Rails.env
        elsif ::ENV.has_key? 'RAILS_ENV'
          ::ENV['RAILS_ENV']
        end
      end
    end
  end
end
