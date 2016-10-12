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
    end
end
