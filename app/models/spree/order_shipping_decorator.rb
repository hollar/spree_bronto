Spree::OrderShipping.class_eval do
  private

  def send_shipment_emails(carton)
    # NOTE(cab): PER SHIPMENT
    carton.orders.each do |order|
      order.shipments.shipped each do |shipment|
        DelayedSend.perform_later(order.email,
                                  external_key(order),
                                  mailer_attributes(shipment, carton))
      end
    end
  end

  def mailer_attributes(shipment, carton)
    Spree::ShipmentMailerAttributes.new(shipment, carton).build_attributes
  end

  def external_key(order)
    _external_key ||= Spree::BrontoConfiguration.
      account[store.code]['order_shipped']
  end

  def store
    Spree::Store.current
  end
end
