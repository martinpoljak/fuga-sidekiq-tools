# encoding: utf-8
# (c) 2016 Martin Poljak (martin@poljak.cz)

require 'sidekiq'

module Fuga
    module Sidekiq
        module Middleware

            ##
            # Provides server middleware for monitoring the
            # status changes.
            #
        
            class JobStatus
                def call(worker, msg, queue)
                    invoke_handler worker, msg, 'Processing'
                    yield
                    invoke_handler worker, msg, 'Completed'
                rescue ::Sidekiq::Shutdown
                    # ignore, will be pushed back onto queue during hard_shutdown
                    raise
                rescue Exception => e
                    invoke_handler worker, msg, 'Failed'
                    raise
                end

                private

                def invoke_handler(worker, msg, status)
                    msg['fuga_job_status'] = status

                    if (f = ::Sidekiq.options[:fuga_job_status]).kind_of? Proc
                        f.call(worker, msg, status)
                    end
                end
            end
	    
        end
    end
end
