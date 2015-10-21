DelayedSend = Struct.new(:store_code, :email, :message_name, :order_id, :plain_view, :html_view) do
  def perform
    return if email.blank?
    bronto_api.trigger_delivery_by_id(message_name,
                                      email,
                                      'transactional',
                                      'html',
                                      bronto_attributes,
                                      email_options)
  rescue
    # handle the transactional contact in case the message
    # is not approved for transactional usage.
    find_or_build_contact
    bronto_api.trigger_delivery_by_id(message_name,
                                      email,
                                      'triggered',
                                      'html',
                                      bronto_attributes,
                                      email_options)
  rescue => exception
    raise exception
  end

  def order
    @order ||= Spree::Order.find(order_id)
  end

  def config
    @config ||= Spree::BrontoConfiguration.account[store_code]
  end

  def bronto_api
    @bronto_api ||= BrontoIntegration::Communication.new(config['token'])
  end

  def find_or_build_contact(email)
    contact = BrontoIntegration::Contact.new(config['token'])
    contact.find_or_create(email)
    contact.update_status(email, 'active')
  end

  def bronto_attributes
    attributes[:First_Name] = order.bill_address.firstname
    attributes[:Last_Name] = order.bill_address.lastname
  end

  def email_options
    @email_options ||= { fromEmail: config['from_address'],
                         fromName: config['from_name'],
                         replyEmail: config['from_address'] }
  end

  if Spree::BrontoConfiguration.account['handle_asynchronously']
    handle_asynchronously :perform, priority: 20
  end
end
