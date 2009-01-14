namespace(:deliver_later) do
  
  desc "Add the Mailings database table"
  task :install => [:environment] do
    ActiveRecord::Schema.define do
      create_table :mail_queue do |t|
        t.column "mail",            :text
        t.column "error_info",      :text
        t.column "read_at",         :datetime
        t.column "sent_at",         :datetime
        t.column "created_at",      :datetime
        t.column "updated_at",      :datetime
      end
      add_index :mail_queue, :read_at
      add_index :mail_queue, :sent_at
    end
  end
  
  desc "Remove the Mailings database table"
  task :uninstall => [:environment] do
    ActiveRecord::Schema.define do
      remove_index :mail_queue, :sent_at
      remove_index :mail_queue, :read_at
      drop_table :mail_queue
    end
  end
  
  task :reinstall => [:uninstall, :install]
  
  desc "Remove all currently queued emails"
  task :clear => [:environment] do
    QueuedMailing.delete_all
  end
  
  desc "Remove all successfully delivered emails"
  task :clear_delivered => [:environment] do
    QueuedMailing.purge_sent!
  end
  
  desc "Deliver all currently queued emails"
  task :deliver_now => [:environment] do
    QueuedMailing.deliver_queued!
  end
  
end
