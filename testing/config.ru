require 'sidekiq'

Sidekiq.configure_client do |config|
  config.redis = { :size => 1, :namespace => 'fuga' }
end

require 'sidekiq/web'
run Sidekiq::Web