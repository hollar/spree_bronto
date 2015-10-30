class BrontoContactAdd < ActiveJob::Base
  queue_as :low_priority

  def perform(email, store_code)
    return if email.blank?
    @email, @store_code = email, store_code
    @contact = BrontoIntegration::Contact.new(bronto_token)

    create_new_contact
    assign_newsletter_status
  end

  private

  attr_reader :contact, :email, :store_code

  def bronto_token
    bronto_config['token']
  end

  def bronto_config
    Spree::BrontoConfiguration.account[store_code]
  end

  def create_new_contact
    contact.find_or_create(email)
  end

  def assign_newsletter_status
    contact.update_status(email, 'onboarding')
  end
end
