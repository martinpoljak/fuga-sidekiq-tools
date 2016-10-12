
class WorkerJob
    include Sidekiq::Worker
    include Fuga::Sidekiq::ErrorHandling
    
    fuga_error Exception,
        :retry => 0, :dead => true

    def perform
        raise Exception::new
    end 
end

# If your client is single-threaded, we just need a single connection in our Redis connection pool
Sidekiq.configure_client do |config|
  config.redis = { :namespace => 'fuga', :size => 1 }
end

# Sidekiq server is multi-threaded so our Redis connection pool size defaults to concurrency (-c)
Sidekiq.configure_server do |config|
    config.redis = { :namespace => 'fuga' }
    
    config.server_middleware do |chain|
        chain.add Fuga::Sidekiq::Middleware::JobStatus
        chain.add Fuga::Sidekiq::Middleware::ErrorHandling
    end

    config.options[:fuga_job_status] = Proc::new do |worker, msg, status|
        p msg, status
    end
end