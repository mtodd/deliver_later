class QueuedMailing < ActiveRecord::Base
  set_table_name "mail_queue"
  
  class << self
    
    # Puts mail into the queue to be emailed later.
    # 
    def enqueue(mail)
      self.create(:mail => mail.encoded)
    end
    
    # Delivers mail.
    # 
    def deliver!(queued_mailing)
      begin
        # mark mailing as read (so we can track errors easier)
        queued_mailing.update_attributes(:read_at => Time.now)
        
        # determine the intended delivery method
        delivery_method = ActionMailer::Base.delivery_method
        ActionMailer::Base.delivery_method = self.intended_delivery_method(delivery_method)
        
        # deliver the email
        ActionMailer::Base.deliver(TMail::Mail.parse(queued_mailing.mail))
        
        # return the delivery method to the deferred version
        ActionMailer::Base.delivery_method = delivery_method
        
        # mark mailing as sent
        queued_mailing.update_attributes(:sent_at => Time.now)
      rescue Exception => e
        # if an exception occurs, record the specific error
        error_info = e.inspect + "\n" + e.message + "\n\t" + e.backtrace.join("\n\t")
        queued_mailing.update_attributes(:error_info => error_info)
      end
    end
    
    # Determines the intended delivery method.
    # 
    # Examples:
    #   intended_delivery_method(:smtp_later)     #=> :smtp
    #   intended_delivery_method(:sendmail_later) #=> :sendmail
    # 
    def intended_delivery_method(method)
      if method.to_s =~ /\A(\w+)_later\Z/
        method = $1
      end
      method.to_sym
    end
    
    # named_scope :queued, :conditions => "read_at IS null AND sent_at IS null" do
    #   def deliver!
    #     find(:all).each do |queued_mailing|
    #       self.deliver!(queued_mailing)
    #     end
    #   end
    # end
    def queued(include_problematic = true)
      if include_problematic
        find(:all, :conditions => "sent_at IS null")
      else
        find(:all, :conditions => "read_at IS null AND sent_at IS null")
      end
    end
    def deliver_queued!
      self.queued.each do |queued_mailing|
        self.deliver!(queued_mailing)
      end
    end
    
    def deliver_queued_with_notification_on_failure!
      previous_problematic = self.problematic.size
      self.deliver_queued!
      problematic_this_batch = self.problematic.size - previous_problematic
      if problematic_this_batch > 0
        STDERR.puts "There were problems sending #{problematic_this_batch} emails"
        
        errors = "\n"
        self.problematic(limit = problematic_this_batch).each do |queued_mailing|
          errors << <<-"end;"
            Error with QueuedMailing(#{queued_mailing.id}):
            ===================================================================
            #{queued_mailing.error_info}
            
          end;
        end
        
        raise errors.gsub("            ", "")
      end
    end
    
    # named_scope :sent, :conditions => "sent_at is not null" do
    #   def purge!(before = Time.now)
    #     find(:all, :conditions => ["sent_at < ?", before]).each do |queued_mailing|
    #       queued_mailing.destroy
    #     end
    #   end
    # end
    def sent(before = Time.now)
      find(:all, :conditions => ["sent_at IS NOT null AND sent_at < ?", before])
    end
    def purge_sent!
      self.sent.each do |queued_mailing|
        queued_mailing.destroy
      end
    end
    
    # named_scope :problematic, :conditions => "sent_at is not null and error_info is not null" do
    #   def resend!
    #     find(:all).each do |queued_mailing|
    #       self.deliver!(queued_mailing)
    #     end
    #   end
    # end
    def problematic(limit = nil)
      find(:all, :conditions => ["read_at IS NOT null AND error_info IS NOT null"], :limit => limit)
    end
    alias :intractible :problematic
    def resend_problematic!
      problematic.each do |queued_mailing|
        self.deliver!(queued_mailing)
      end
    end
    alias :resend_intractible! :resend_problematic!
    
  end
  
end
