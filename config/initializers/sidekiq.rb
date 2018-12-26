REDIS_URL = ENV.fetch("REDIS_URL"){"redis://localhost:6379/3"}

Sidekiq.configure_server do |config|
  config.redis = {url: REDIS_URL}
end

Sidekiq.configure_client do |config|
  config.redis = {url: REDIS_URL}
end
