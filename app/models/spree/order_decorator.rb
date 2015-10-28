Spree::Order.class_eval do
  def deliver_order_confirmation_email
    if handle_asynchronously?
      send_email('order_received')
    else
      OrderMailer.confirm_email(self).deliver_later
    end
    update_column(:confirmation_delivered, true)
  end

  private

  def handle_asynchronously?
    Spree::BrontoConfiguration['handle_asynchronously']
  end

  def send_cancel_email
    if handle_asynchronously?
      send_email('order_canceled')
    else
      OrderMailer.cancel_email(self).deliver_later
    end
  end

  def send_email(key)
    DelayedSend.perform_later(email,
                              id,
                              external_key[key])
  end

  def external_key
    _external_key ||= Spree::BrontoConfiguration
                      .account[store.code]
  end

  def store
    Store.current
  end
end
