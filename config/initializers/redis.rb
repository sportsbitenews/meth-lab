# -*- encoding : utf-8 -*-
REDIS_CONFIG = YAML.load(File.open("#{Rails.root}/config/redis.yml")).with_indifferent_access[Rails.env].merge(:thread_safe => true, :timeout => 10)
REDIS_CONFIG_USERS = YAML.load(File.open("#{Rails.root}/config/redis_users.yml")).with_indifferent_access[Rails.env].merge(:thread_safe => true)

$redis = Redis.new(REDIS_CONFIG)
$redis_secondary = $redis_users = REDIS_USERS = Redis.new(REDIS_CONFIG_USERS)

# Redis::Objects.redis = Redis.new(REDIS_CONFIG)    

#Rails.feature_manager.engine = $redis
