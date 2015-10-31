Spree::Order.class_eval do
  def deliver_order_confirmation_email
    send_email('order_received')
    update_column(:confirmation_delivered, true)
  end

  private

  def send_cancel_email
    send_email('order_canceled')
  end

  def send_email(key)
    DelayedSend.perform_later(email,
                              external_key[key],
                              mailer_attributes)
  end

  def mailer_attributes
    Spree::OrderMailerAttributes.new(self).build_attributes
  end

  def external_key
    _external_key ||= Spree::BrontoConfiguration
                      .account[store.code]
  end

  def store
    Spree::Store.current
  end
end
