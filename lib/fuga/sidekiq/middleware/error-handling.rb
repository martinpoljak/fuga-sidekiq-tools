# encoding: utf-8
# (c) 2016 Martin Poljak (martin@poljak.cz)

require 'sidekiq'

module Fuga
    module Sidekiq
        module Middleware

            ##
            # Catches the job errors and applies their settings.
            #

            class ErrorHandling

                def call(worker, msg, queue)
                    yield
                rescue ::Sidekiq::Shutdown
                    # ignore, will be pushed back onto queue during hard_shutdown
                    raise
                rescue Exception => e
                    # merges the error handling settings into the message 
                    # for RetryJobs middleware
                    if opts = msg['fuga_error_handling'][e.class.name]
                        msg.merge! opts
                    end

                    # raises to be cought by RetryJobs middleware
                    # in next step
                    raise
                end

            end
        end

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
