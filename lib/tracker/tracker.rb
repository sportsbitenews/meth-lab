# -*- encoding : utf-8 -*-
module Tracker

  # tracks any action by its name
  # example:
  # action => 'page_view'
  # item => url
  def track_action(action, item = '')
    Tracker.track_action(self, action, item)
  end

  # returns a list of tracked items for a specific action, ordered by thier score
  # example:
  # action => 'page_view' 
  # may return [www.google.com, www.facebook.com, www.cnn.com]
  def tracked_items_by_top_score(action)
    Tracker.top_scoring_items_for_action(self, action)
  end
  
  def score_for_item(action, item)
    Tracker.score(self, action, item)
  end
  
  def top_scoring_items_for_action(action, max_results = 50, object = nil)
    Tracker.top_scoring_items_for_action(action, max_results, self)
  end

  
  def self.track_action(action, item = '', object = nil)
    begin
      # track specific object
      $redis.zincrby("tracker:#{action}:#{object.class.name.downcase == 'string' ? object : object.id}", 1, item.downcase) if !object.nil?
      #add to global tracker
      Tracker.track_aggregated_action(action, item.downcase)
    rescue
    end   
  end

  def self.reset_action_count(action, item, object = nil)
    $redis.zadd("tracker:#{action}:#{object.class.name.downcase == 'string' ? object : object.id}", 0, item.downcase) if !object.nil?
    $redis.zadd("tracker:#{action}:global", 0, item.downcase)
  end

  def self.delete_action_tracker(action, object = nil)
    $redis.del "tracker:#{action}:#{object.class.name.downcase == 'string' ? object : object.id}" unless object.nil?
    $redis.del "tracker:#{action}:global"
  end

  def self.top_scoring_items_for_action(action, max_results = 50, object = nil)
    begin
      if object.nil?
        $redis.zrange("tracker:#{action}:global",(max_results * -1),-1).reverse
      else
        $redis.zrange("tracker:#{action}:#{object.id}",(max_results * -1), -1).reverse
      end
    rescue
      []
    end   
  end
  
  def self.score(action, item, object = nil)
    begin
      if object.nil?
        $redis.zscore("tracker:#{action}:global",item.downcase)
      else
        $redis.zscore("tracker:#{action}:#{object.id}",item.downcase)
      end
    rescue
      0
    end
  end

  # global tracking
  def self.track_aggregated_action(action, item = '')
    begin
      $redis.zincrby("tracker:#{action}:global", 1, item.downcase)
    rescue
    end
  end

  # Track key-value counters in hashes with O(1) complexity
  # and allow key expiry

  def self.incr_counter(key, value = nil, expire = nil, always_expire = true)
    begin
      if value.present?
        $redis.hincrby( key, value, 1 )
      else
        $redis.incrby( key, 1 )
      end
      if expire.present? && (always_expire || $redis.ttl(key) == -1 )
        $redis.expire(key, expire)
      end
    rescue
    end
  end

  def self.read_counter(key, value = nil)
    begin
      if value.present?
        return $redis.hget( key, value ).to_i
      else
        return $redis.get( key ).to_i
      end
    rescue
      return 0
    end
  end

  def self.counter_length(key)
    $redis.hlen( key ).to_i
  end
end