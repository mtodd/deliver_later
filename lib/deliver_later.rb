module DeliverLater
  
  VERSION = [0, 2, 1]
  
  class << self
    
    def version
      VERSION.join('.')
    end
    
  end
  
  def method_missing(delivery_method, *args)
    if delivery_method.to_s =~ /\Aperform_delivery_(\w+)_later\Z/
      send("perform_delivery_later", *args)
    else
      super
    end
  end
  
  # Enqueue the mail to be delivered in the 2nd phase.
  # 
  # This method is called when the delivery method is appended with
  # <tt>_later</tt>, such as:
  # 
  #   config.actionmailer.delivery_method = :smtp_later
  # 
  # Since +perform_delivery_smtp_later+ does not exist, it gets caught and sent
  # to this method to be queued.
  # 
  # Any <tt>_later</tt> delivery method will be queued up unless one is
  # specifically added.
  # 
  def perform_delivery_later(mail)
    QueuedMailing.enqueue(mail)
  end
  
end
