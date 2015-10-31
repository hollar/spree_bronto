class OrderMailerAttributes
  def initialize(order)
    @order = order
    @attrs = {}
  end

  def build_attributes
    build_message_tags
    build_loop_tags
    attrs
  end

  private

  attr_reader :order, :attrs

  def build_message_tags
    attrs[:orderIncrementId] = order.number
    attrs[:orderShippingDescription] = order.shipments.first.shipping_method.name
    attrs[:shipmentTracking] = order.shipments.first.tracking
    attrs[:orderTotals] = order.total.to_i
  end

  def build_loop_tags
    attrs[:'productImgUrl_#'] = order.line_items.map { |i| i.variant.images.first.attachment.url(:small) }
    attrs[:'productName_#'] = order.line_items.map { |i| i.variant.name }
    attrs[:'productSku_#'] = order.line_items.map { |i| i.variant.sku }
    attrs[:'productQty_#'] = order.ine_items.map(&:quantity)
    attrs[:'productPriceExclTax_#'] = order.line_items.map { |i| i.price.to_i }
  end

end
