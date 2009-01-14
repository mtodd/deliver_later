module DeliverLater
  
  def method_missing(delivery_method, *args)
    if delivery_method.to_s =~ /\Aperform_delivery_(\w+)_later\Z/ and
       delivery_method = $1
       # respond_to?("perform_delivery_#{delivery_method}".to_sym)
      send("perform_delivery_later", delivery_method, *args)
    else
      super
    end
  end
  
  def perform_delivery_later(delivery_method, mail)
    QueuedMailing.enqueue(mail)
  end
  
end
