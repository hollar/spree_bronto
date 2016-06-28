class DelayedSend < ActiveJob::Base
  queue_as :medium_priority

  def perform(email, message_name, attributes = {})
    return if email.blank?
    begin
      bronto_api.trigger_delivery_by_id(message_name,
                                        email,
                                        'transactional',
                                        'html',
                                        attributes,
                                        email_options)
    rescue
      begin
        bronto_api.trigger_delivery_by_id(message_name,
                                          email,
                                          'triggered',
                                          'html',
                                          attributes,
                                          email_options)
      rescue => e
        raise e
      end
    end
  end

  private

  def config
    @config ||= Spree::BrontoConfiguration.account[store_code]
  end

  def bronto_api
    @bronto_api ||= BrontoIntegration::Communication.new(config['token'])
  end

  def email_options
    @email_options ||= { fromEmail: config['from_address'],
                         fromName: config['from_name'],
                         replyEmail: config['from_address'] }
  end

  def store_code
    Spree::Store.current.code
  end
end
