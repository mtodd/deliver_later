Gem::Specification.new do |s|
  s.name     = "deliver_later"
  s.version  = "0.2.1"
  s.date     = "2009-01-14"
  s.summary  = "A 2-phase database-backed ActionMailer delivery method"
  s.email    = "mtodd@highgroove.com"
  s.homepage = "http://github.com/mtodd/deliver_later"
  s.description = "DeliverLater is a Rails plugin providing a 2-phase database-backed ActionMailer delivery method"
  s.has_rdoc = true
  s.authors  = ["Matt Todd"]
  s.files    = [
    "app/models/queued_mailing.rb",
    "deliver_later.gemspec",
    "init.rb",
    "install.rb",
    "lib/deliver_later.rb",
    "README.textile",
    "tasks/deliver_later_tasks.rake"]
  s.test_files = []
  s.rdoc_options = ["--main", "README.textile"]
  s.extra_rdoc_files = ["README.textile"]
  s.add_dependency("rails", ["> 1.1.3"])
end
