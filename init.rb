require 'deliver_later'
ActionMailer::Base.send :include, DeliverLater

models = File.join(File.dirname(__FILE__), 'app', 'models')
$LOAD_PATH              << models
Dependencies.load_paths << models
