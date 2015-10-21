module Spree
  User.class_eval do
    has_and_belongs_to_many :bronto_lists, class_name: 'Spree::BrontoList',
                                           join_table: :spree_bronto_lists_users
    accepts_nested_attributes_for :bronto_lists

    def send_devise_notification(notification, *args)
      # Bronto sending
      # trigger the email directly here.
      bronto_api.trigger_delivery_by_id(bronto_config[notification.to_s],
                                           email, 'transactional', 'html',
                                           message_attributes, email_options)
    rescue
      # handle the transactional contact in case the
      # message is not approved for transactional.
      find_or_build_contact(email)
      bronto_api.trigger_delivery_by_id(bronto_config[notification.to_s],
                                           email, 'triggered', 'html',
                                           attributes, email_options)
    rescue => exception
      raise exception
    end

    private

    def bronto_api
      client ||= BrontoIntegration::Communication.new(bronto_token)
    end

    def current_store
      _current_store ||= Spree::Store.current
    end

    def store_code
      current_store.code
    end

    def email_options
      { fromEmail: from_email, fromName: from_name, replyEmail: reply_email }
    end

    def from_email
      current_store.mail_from_address
    end

    def recent_order
      orders.complete.last
    end

    def from_name
      bronto_config['from_name']
    end

    def reply_email
      current_store.mail_from_address
    end

    def find_or_build_contact(email)
      contact = BrontoIntegration::Contact.new(bronto_token)
      contact.find_or_create(email)
      contact.update_status(email, 'active')
    end

    def bronto_attributes
      attributes = {}
      if recent_order
        attributes[:First_Name] = recent_order.ship_address.firstname
        attributes[:Last_Name] = recent_order.ship_address.lastname
      end
      attributes[:SENDTIME__CONTENT1] = reset_password_token
    end

    def bronto_token
      bronto_config['token']
    end

    def bronto_config
      Spree::BrontoConfiguration.account[store_code]
    end
  end
end
