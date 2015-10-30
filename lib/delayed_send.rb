class DelayedSend < ActiveJob::Base
  queue_as :medium_priority

  def perform(email, order_id, message_name)
    return if email.blank?
    @email, @order_id = email, order_id,
    bronto_api.trigger_delivery_by_id(message_name,
                                      email,
                                      'triggered',
                                      'html',
                                      bronto_attributes,
                                      email_options)
  end

  private

  attr_reader :email, :order_id

  def order
    @order ||= Spree::Order.find(order_id)
  end

  def config
    @config ||= Spree::BrontoConfiguration.account[store_code]
  end

  def bronto_api
    @bronto_api ||= BrontoIntegration::Communication.new(config['token'])
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

  def store_code
    order.store.code
  end
end
