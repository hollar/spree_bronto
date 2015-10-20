module Spree
  User.class_eval do
    has_and_belongs_to_many :bronto_lists, class_name: 'Spree::BrontoList',
                                           join_table: :spree_bronto_lists_users
    accepts_nested_attributes_for :bronto_lists

    def send_devise_notification(notification, *args)
      # @edit_password_reset_url = edit_spree_user_password_url(:reset_password_token => token, :host => current_store.url)
      # mail to: user.email, from: from_address, subject: Spree::Store.current.name + ' ' + I18n.t(:subject, :scope => [:devise, :mailer, :reset_password_instructions])
      # Bronto sending
      # trigger the email directly here.
      communication = BrontoIntegration::Communication.new(bronto_token)
      communication.trigger_delivery_by_id(bronto_message, email,
                                           'transactional', 'html',
                                           message_attributes, email_options)
    rescue
      # handle the transactional contact in case the
      # message is not approved for transactional.
      contact = BrontoIntegration::Contact.new(bronto_token)
      contact.update_status(email, 'active')
      communication.trigger_delivery_by_id(bronto_message, email,
                                           'triggered', 'html',
                                           attributes, email_options)
    rescue => exception
      raise exception
    end

    private

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

    def bronto_attributes
      attributes = {}
      attributes = {:First_Name => recent_order.ship_address.firstname} if recent_order
      attributes = {:First_Name => recent_order.ship_address.lastname} if recent_order
      attributes[:SENDTIME__CONTENT1] = reset_password_token
    end

    def bronto_message
      bronto_config['password_reset']
    end

    def bronto_token
      bronto_config['token']
    end

    def bronto_config
      Spree::BrontoConfiguration.account[store_code]
    end
  end
end
