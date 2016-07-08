config = YAML.load(ERB.new(File.read("#{Rails.root}/config/redis.yml")).result)[Rails.env].symbolize_keys

local_config_file = "#{Rails.root}/config/redis_local.yml"
if File.exist?(local_config_file)
  local_config = YAML.load(ERB.new(File.read(local_config_file)).result)
  if local_config && local_config[Rails.env]
    config = config.merge local_config[Rails.env].symbolize_keys
  end
end

if config[:namespace].blank?
  $redis = Redis.new config
else
  $redis = Redis::Namespace.new config[:namespace], redis: Redis.new(config)
end

# raise exception if connection failed
$redis.ping

# don't use flushdb, it does not respect namespace
if Rails.env.test?
  keys = $redis.keys('*')
  unless keys.empty?
    $redis.del keys
  end
end
