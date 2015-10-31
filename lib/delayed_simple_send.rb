class DelayedSimpleSend < ActiveJob::Base
  queue_as :high_priority

  def perform(email, message_name, attributes={})
    return if email.blank?
    bronto_api.trigger_delivery_by_id(message_name,
                                      email,
                                      'triggered',
                                      'html',
                                      attributes,
                                      email_options)
  end

  def config
    @config ||= Spree::BrontoConfiguration.account[store_code]
  end

  def bronto_api
    @bronto_api ||= BrontoIntegration::Communication.new(config['token'])
  end

  def email_options
    @email_options ||= { fromEmail: from_email,
                         fromName: from_name,
                         replyEmail: from_email }
  end

  def from_name
    config['from_name']
  end

  def from_email
    config['from_address']
  end

  def current_store
    _current_store ||= Spree::Store.current
  end

  def store_code
    current_store.code
  end
end
