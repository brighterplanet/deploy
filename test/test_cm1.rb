require 'helper'

class TestCm1 < Test::Unit::TestCase
  def setup
    FakeWeb.clean_registry
    FakeWeb.allow_net_connect = false
    {
      'http://carbon.brighterplanet.com/brighter_planet_deploy/color' => 'blue',
    }.each do |url, body|
      FakeWeb.register_uri :get, url, :status => ["200", "OK"], :body => body
    end
    FakeFS.activate!

    FileUtils.mkdir_p '/data/randomeyappname/current/config/brighter_planet_deploy'
    File.open('/data/randomeyappname/current/config/brighter_planet_deploy/resque_redis_url', 'w') { |f| f.write "redis://username:password@hostname.redistogo.com:9000/[STATUS]:resque" }
    File.open('/data/randomeyappname/current/config/brighter_planet_deploy/phase', 'w') { |f| f.write 'edge' }
    File.open('/data/randomeyappname/current/config/brighter_planet_deploy/service', 'w') { |f| f.write 'cm1' }
    
    FileUtils.mkdir_p '/data/randomeyappname/current/public/brighter_planet_deploy'
    File.open('/data/randomeyappname/current/public/brighter_planet_deploy/color', 'w') { |f| f.write 'blue' }
    
    @me = BrighterPlanet.deploy.servers.me
    @me.rails_root = '/data/randomeyappname/current'
  end
  
  def teardown
    FakeWeb.clean_registry
    FakeWeb.allow_net_connect = true
    FakeFS.deactivate!
  end
  
  def test_001_color
    assert_equal 'blue', @me.color
    assert_equal 'blue', BrighterPlanet.deploy.emission_estimate_service.color
  end
    
  def test_003_service
    assert_equal 'EmissionEstimateService', BrighterPlanet.deploy.emission_estimate_service.name
    assert_equal 'EmissionEstimateService', @me.service_class.name
  end
  
  def test_004_status
    assert_equal :active, @me.status
  end
  
  def test_005_resque_redis_url
    assert @me.resque_redis_url.start_with?('redis://')
    assert @me.resque_redis_url.include?('active')
  end
  
  def test_006_write_config
    @me.write_config :public => { :color => '-bar-' }, :private => { :resque_redis_url => 'foo[COLOR]baz' }
    assert_equal '-bar-', @me.color
    assert_equal 'foo-bar-baz', @me.resque_redis_url
  end
  
  def test_007_save_config
    @me.color = '-zzz-'
    @me.resque_redis_url = 'fie[COLOR]bang'
    @me.save_config
    me2 = BrighterPlanet.deploy.servers.me
    me2.rails_root = '/data/randomeyappname/current'
    assert_equal '-zzz-', me2.color
    assert_equal 'fie-zzz-bang', me2.resque_redis_url
  end
    
  # not sure this should be included
  def test_008_phase
    assert_equal 'edge', @me.phase
  end
end
