module Spree
  class OrderMailerAttributes
    def initialize(order, carton)
      @order = order
      @carton = carton
      @attrs = {}
    end

    def build_attributes
      build_message_tags
      build_line_item_tags
      build_address_tags('bill')
      build_address_tags('ship')
      build_payment_tags
      attrs
    end

    private

    attr_reader :order, :attrs, :carton

    def build_message_tags
      attrs[:orderIncrementId] = order.number
      attrs[:orderShippingDescription] = carton.shipping_method.name
      attrs[:shipmentTracking] = carton.tracking
      attrs[:orderTotals] = order.total.to_i
      attrs[:orderSubTotals] = order.item_total.to_i
      attrs[:orderTaxTotals] = order.tax_total.to_i
      attrs[:orderShippingTotals] = order.shipment_total.to_i
    end

    def build_line_item_tags
      order.line_items.each_with_index do |item, idx|
        attrs[:"productImgUrl_#{idx}"] = item.variant.images.first.attachment.url(:small)
        attrs[:"productName_#{idx}"] = item.variant.name
        attrs[:"productSku_#{idx}"] = item.variant.sku
        attrs[:"productQty_#{idx}"] = item.quantity
        attrs[:"productPriceExclTax_#{idx}"] = item.price.to_i
      end
    end

    def build_payment_tags
      attrs[:paymentType] = order.payments.completed.first.source.cc_type
      attrs[:paymentNumber] = order.payments.completed.first.source.last_digits
    end

    def build_address_tags(type)
      attrs[:"#{type}Name"] = "#{address_for(type).firstname} #{address_for(type).lastname}"
      address_street_block(type)
      address_city_block(type)
      attrs[:"#{type}Country"] = address_for(type).country.name
    end

    def address_street_block(type)
      attrs[:"#{type}StreetAddress"] = address_for(type).address1
      return unless address_for(type).address2
      attrs[:"#{type}StreetAddress"] += "\n #{address_for(type).address2}"
    end

    def address_city_block(type)
      attrs[:"#{type}CityLine"] = "#{address_for(type).city}, #{address_for(type).zipcode}"
      return unless address_for(type).state
      attrs[:"#{type}CityLine"] = "#{address_for(type).city}, #{address_for(type).state.name}, #{address_for(type).zipcode}"
    end

    def address_for(type)
      order.send(:"#{type}_address")
    end
  end
end
