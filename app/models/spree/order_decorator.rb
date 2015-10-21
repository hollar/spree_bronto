Spree::Order.class_eval do
  def deliver_order_confirmation_email
    DelayedSend.new(store.code,
                    email,
                    external_key['order_received'],
                    id.to_s,
                    'order_mailer/order_confirm_plain',
                    'order_mailer/order_confirm_html').perform

    update_column(:confirmation_delivered, true)
  end

  private

  def send_cancel_email
    DelayedSend.new(store.code,
                    email,
                    external_key['order_canceled'],
                    id.to_s,
                    'order_mailer/order_cancel_plain',
                    'order_mailer/order_cancel_html').perform
  end

  def external_key
    _external_key ||= Spree::BrontoConfiguration
                      .account[store.code]
  end
end
