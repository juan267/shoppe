require 'csv'
module Shoppe
  class Customer < ActiveRecord::Base
    EMAIL_REGEX = /\A\b[A-Z0-9\.\_\%\-\+]+@(?:[A-Z0-9\-]+\.)+[A-Z]{2,6}\b\z/i
    PHONE_REGEX = /(?:\+?(\d{1,3}))?[-. (]*(\d{1,3})?[-. )]*(\d{3})[-. ]*(\d{4})(?: *x(\d+))?/

    self.table_name = 'shoppe_customers'

    has_many :addresses, dependent: :restrict_with_exception, class_name: 'Shoppe::Address'

    has_many :orders, dependent: :restrict_with_exception, class_name: 'Shoppe::Order'

    # Validations
    before_validation :downcase_email

    validates :email, presence: true, uniqueness: true, format: { with: EMAIL_REGEX }
    validates :phone, presence: true, format: { with: PHONE_REGEX }

    # All customers ordered by their ID desending
    scope :ordered, -> { order(id: :desc) }
    scope :created_between, lambda {|start_date, end_date| where("created_at >= ? AND created_at <= ?", start_date, end_date )}

    # The name of the customer in the format of "Company (First Last)" or if they don't have
    # company specified, just "First Last".
    #
    # @return [String]
    def name
      company.blank? ? full_name : "#{company} (#{full_name})"
    end

    def lifetime_value
      orders.ordered.reduce(0) {|accu, order| accu += order.amount_paid.to_i}
    end

    def order_count
      orders.completed.count
    end

    def self.to_csv
      headers = %w{first_name last_name address city phone email sign_up_date order_count lifetime_value}
      attributes = %w{first_name last_name addresses city phone email created_at order_count lifetime_value}

      CSV.generate(headers: true) do |csv|
        csv << headers
        all.each do |user|
          csv << attributes.map do |attr|
           address = user.addresses.to_a.first
           if attr == 'addresses'
             address.try(:full_address)
           elsif attr == 'created_at'
             user.created_at.strftime("%B %-d, %Y")
           elsif attr == 'order_count'
             user.order_count
           elsif attr == 'city'
             address.try(:address3)
           elsif attr == 'lifetime_value'
             user.lifetime_value
           else
             user.send(attr)
           end
          end
        end
      end
    end

    # The full name of the customer created by concatinting the first & last name
    #
    # @return [String]
    def full_name
      "#{first_name} #{last_name}"
    end

    def self.ransackable_attributes(_auth_object = nil)
      %w(id first_name last_name company email phone mobile) + _ransackers.keys
    end

    def self.ransackable_associations(_auth_object = nil)
      []
    end

    private

    def downcase_email
      self.email = email.downcase if email.present?
    end
  end
end
