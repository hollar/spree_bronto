DelayedSimpleSend = Struct.new(:store_code, :email, :message_name, :attributes, :mail_type, :priority) do
  def perform
    return if email.blank?
    bronto_api.trigger_delivery_by_id(message_name,
                                      email,
                                      'triggered',
                                      mail_type || 'html',
                                      attributes || {},
                                      email_options)
  end

  handle_asynchronously :perform, priority: priority || 20

  def config
    @config ||= Spree::BrontoConfiguration.account[store_code]
  end

  def bronto_api
    @bronto_api ||= BrontoIntegration::Communication.new(token['token'])
  end

  def email_options
    { fromEmail: from_email, fromName: from_name, replyEmail: from_email }
  end

  def from_email
    @from_email ||= config['from_name']
  end

  def reply_email
    @reply_email ||= config['from_address']
  end
end
