Spree::OrderShipping.class_eval do
    private

    def send_shipment_emails(carton)
      carton.orders.each do |order|
        DelayedSend.perform_later(order.email,
                                  order.id,
                                  external_key(order))
      end
    end

    def external_key(order)
      _external_key ||= Spree::BrontoConfiguration.
                        account[order.store.code]['order_shipped']
    end
end
