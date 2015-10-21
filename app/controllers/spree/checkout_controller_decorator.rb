Spree::CheckoutController.class_eval do
  include Spree::Lists
  before_action :check_newsletter

  def load_order
    @order = current_order
    @bronto_lists = current_store.bronto_lists.select{|l| l.visible && !l.subscribe_all_new_users}
    redirect_to spree.cart_path and return unless @order
  end

  private

  def check_newsletter
    if params['bronto_list']
      params['bronto_list'].each do |k, v|
        list = Spree::BrontoList.find(k)
        if k && v && @order.email
          subscribe_to_list(@order.email, list)
        end
      end
    end
  end

end
