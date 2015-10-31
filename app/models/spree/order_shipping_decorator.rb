Spree::OrderShipping.class_eval do
    private

    def send_shipment_emails(carton)
      carton.orders.each do |order|
        DelayedSend.perform_later(order.email,
                                  external_key(order),
                                  mailer_attributes(order))
      end
    end

    def mailer_attributes(order)
      Spree::OrderMailerAttributes.new(order).build_attributes
    end

    def external_key(order)
      _external_key ||= Spree::BrontoConfiguration.
                        account[store.code]['order_shipped']
    end

    def store
      Spree::Store.current
    end
end
