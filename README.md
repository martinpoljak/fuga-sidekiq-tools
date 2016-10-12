Fuga Sidekiq Tools
========

**fuga-sidekiq-tools** implements two [Sidekiq][1] extensions per unnamed company (try to guess which one! finally someone who uses Ruby in Amsterdam in reasonable way) request:

* per exception type error handling,
* simple callback for tracking job status changes.

###  Error handling

In Sidekiq, failed jobs policy can be defined only on job level, but sometime, you can need to distinguish them it on basis of different exception types. Here, it's implemented by two components:

* `Fuga::Sidekiq::Middleware::ErrorHandling` server middleware,
* `Fuga::Sidekiq::ErrorHandling` worker mixin.

*Mixin* provides simple API (well, class method) for definying policies, middleware ensures setting them before job is passed to subsequent middlewares, usually`RetryJobs` middleware ensuring retrying and dead queue handling. But it's usable generally for setting any job options on basis of exception type.

Use it by the following way:

```ruby
require 'fuga/sidekiq/middleware/error-handling'
require 'fuga/sidekiq/error-handling'
require 'sidekiq'

# install the middleware
Sidekiq.configure_server do |config|
    config.server_middleware do |chain|
        chain.add Fuga::Sidekiq::Middleware::ErrorHandling
    end
end

# define policies in worker
class FooJob
    include Sidekiq::Worker
    include Fuga::Sidekiq::ErrorHandling
    
    # default options
    sidekiq_options \
        :retry => 2, :dead => true
        
    # specific policies
    fuga_error FatalError,
        :retry => 0, :dead => true
    fuga_error SoftError,
        :retry => 8, :dead => false

    def perform
        raise FatalError::new	 # will go to dead queue immediately
    end 
end
```

In case, other than declared exceptions are thrown, the normal default settings set by `sidekiq_options` are used. Note, to keep it simple (I really don't like complicated things), it doesn't analyze genericity, so in case, you need to deal with tree of exceptions, perhaps will be necessary to declare all of them.

### Job status tracking

To track job status is quite simple except tracking the initial `Queued` state because it's done directly by client and what is worse, Sidekiq uses lists for this task expcet something like Redis pubsub mechanism, therefore it's somehow difficult (despite I believe possible) to hack into this process.

But to track other states like `Processed`, `Completed` and `Failed` can be tracked simply by:

* `Fuga::Sidekiq::Middleware::JobStatus` server middleware.

Configure and use it by the following way:

```ruby
require 'sidekiq'
require 'fuga/sidekiq/middleware/job-status'

Sidekiq.configure_server do |config|

    # configure it
    config.options[:fuga_job_status] = Proc::new do |worker, msg, status|
         # in 'worker' is server instance of your job
         # in 'msg' is your job specification (ID and so)
         # in 'status' is just the status string
    end
    
    # install middleware
    config.server_middleware do |chain|
        chain.add Fuga::Sidekiq::Middleware::JobStatus
    end
    
end
```


### Copyright

Copyright &copy; 2016 [Martin Poljak][2]. See `LICENSE.txt` for further details.

[1]: http://sidekiq.org
[2]: https://www.martinpoljak.net/
