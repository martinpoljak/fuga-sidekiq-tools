# encoding: utf-8
# (c) 2016 Martin Poljak (martin@poljak.cz)

require 'sidekiq'

module Fuga
    module Sidekiq

        ##
        # Provides worker API for definying the error handling settings for 
        # different types of exceptions.
        #
        
        module ErrorHandling
            def self.included(base)
                base.extend(ClassMethods)
            end

            module ClassMethods
                def fuga_error(e, options = { })
		    # adds the exception settings to the job configuration
                    get_sidekiq_options['fuga_error_handling'] ||= { }
                    get_sidekiq_options['fuga_error_handling'][e.name] = options.stringify_keys
                end
            end 
        end
	
    end
end
