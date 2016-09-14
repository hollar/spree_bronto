module Spree
  User.class_eval do
    has_and_belongs_to_many :bronto_lists, class_name: 'Spree::BrontoList',
                                           join_table: :spree_bronto_lists_users
    accepts_nested_attributes_for :bronto_lists
    after_commit :create_bronto_contact, on: :create

    def send_devise_notification(notification, *args)
      DelayedSimpleSend.perform_later(email,
                                      bronto_config[notification.to_s],
                                      bronto_attributes(args))
    end

    private

    def recent_order
      orders.complete.last
    end

    def create_bronto_contact
      begin
        contact = BrontoIntegration::Contact.new(bronto_token)
        contact.find_or_create(email)
        contact.update_status(email, 'active')
      rescue
        # noop
      end
    end

    def bronto_attributes(args)
      attributes = {}
      if recent_order
        attributes[:First_Name] = recent_order.ship_address.firstname
        attributes[:Last_Name] = recent_order.ship_address.lastname
      end
      attributes[:resetToken] = args[0]
      attributes
    end

    def bronto_token
      bronto_config['token']
    end

    def bronto_config
      Spree::BrontoConfiguration.account[store_code]
    end

    def current_store
      _current_store ||= Spree::Store.current
    end

    def store_code
      current_store.code
    end
  end
end
