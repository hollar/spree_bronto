module Spree
  class OrderMailerAttributes
    def initialize(order)
      @order = order
      @attrs = {}
    end

    def build_attributes
      build_message_tags
      build_line_item_tags
      build_payment_tags
      attrs
    end

    private

    attr_reader :order, :attrs

    def build_message_tags
      attrs[:orderIncrementId] = order.number
      attrs[:orderShippingDescription] = order.shipments.first.shipping_method.name
      attrs[:shipmentTracking] = order.shipments.first.tracking
      attrs[:orderTotals] = order.total.to_i
      attrs[:orderSubTotals] = order.item_total.to_i
      attrs[:orderTaxTotals] = order.tax_total.to_i
      attrs[:orderShippingTotals] = order.shipment_total.to_i
    end

    def build_payment_tags
      attrs[:paymentType] = order.payments.valid.first.source.cc_type
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
  end
end
