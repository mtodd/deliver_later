require 'deliver_later'
ActionMailer::Base.send :include, DeliverLater

# check that we're rails-2.3 and that we're loading app paths via the
# Rails::Plugin loader process.  if both of those things are true, we
# don't need to do any more shenanigans to get deviler_later loaded.
# note: this isn't fantastic, specifically checking to see if a
# private method exists in light of the fact the api could change, but
# it is a pretty good check to see if we'll need to do additional
# loading
unless ActiveSupport.const_defined?(:Dependencies) && Rails.const_defined?(:Plugin) && Rails::Plugin.private_instance_methods.include?("app_paths")
  models = File.join(File.dirname(__FILE__), 'app', 'models')
  $LOAD_PATH              << models
  Dependencies.load_paths << models
end
