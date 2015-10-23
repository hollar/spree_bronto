Spree::Order.class_eval do
  def deliver_order_confirmation_email
    DelayedSend.perform_later(email,
                              id,
                              external_key['order_received'])
    update_column(:confirmation_delivered, true)
  end

  private

  def send_cancel_email
    DelayedSend.perform_later(email,
                              id,
                              external_key['order_canceled'])
  end

  def external_key
    _external_key ||= Spree::BrontoConfiguration
                      .account[store.code]
  end
end
