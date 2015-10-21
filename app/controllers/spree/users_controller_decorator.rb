Spree::UsersController.class_eval do
  include Spree::Lists

  before_action :load_bronto_lists
  before_action :check_newsletter

  private

  attr_reader :bronto_lists, :list, :user

  def load_bronto_lists
    @bronto_lists = current_store.bronto_lists
  end

  def check_newsletter
    return unless user_subscribing? && user
    params['user']['bronto_list_attributes'].each do|k, v|
      subscribe_user(list(k)) if v == 'true'
      unsubscribe_user(list(k)) if v == 'false'
    end
  end

  def unsubscribe_user(list)
    return unless list
    unsubscribe_from_list(user, list)
  end

  def subscribe_user(list)
    return unless list
    subscribe_to_list(user, list)
  end

  def list(name)
    Spree::BrontoList.find(name)
  end

  def user_subscribing?
    params['user'] && params['user']['bronto_list_attributes']
  end
end
