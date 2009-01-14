Dir.chdir File.join(File.dirname(__FILE__), '..', '..', '..') do
  `rake deliver_later:install`
end
