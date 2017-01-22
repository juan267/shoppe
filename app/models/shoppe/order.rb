require 'csv'
module Shoppe
  class Order < ActiveRecord::Base
    EMAIL_REGEX = /\A\b[A-Z0-9\.\_\%\-\+]+@(?:[A-Z0-9\-]+\.)+[A-Z]{2,6}\b\z/i
    PHONE_REGEX = /(?:\+?(\d{1,3}))?[-. (]*(\d{1,3})?[-. )]*(\d{3})[-. ]*(\d{4})(?: *x(\d+))?/

    self.table_name = 'shoppe_orders'

    # Orders can have properties
    key_value_store :properties

    # Require dependencies
    require_dependency 'shoppe/order/states'
    require_dependency 'shoppe/order/actions'
    require_dependency 'shoppe/order/billing'
    require_dependency 'shoppe/order/delivery'

    # All items which make up this order
    has_many :order_items, dependent: :destroy, class_name: 'Shoppe::OrderItem', inverse_of: :order
    accepts_nested_attributes_for :order_items, allow_destroy: true, reject_if: proc { |a| a['ordered_item_id'].blank? }

    # All products which are part of this order (accessed through the items)
    has_many :products, through: :order_items, class_name: 'Shoppe::Product', source: :ordered_item, source_type: 'Shoppe::Product'

    # The order can belong to a customer
    belongs_to :customer, class_name: 'Shoppe::Customer'
    has_many :addresses, through: :customers, class_name: 'Shoppe::Address'

    # Validations
    validates :token, presence: true
    with_options if: proc { |o| !o.building? } do |order|
      order.validates :email_address, format: { with: EMAIL_REGEX }
      order.validates :phone_number, format: { with: PHONE_REGEX }
    end

    scope :created_between, lambda {|start_date, end_date| where("received_at >= ? AND received_at <= ?", start_date, end_date )}

    # Set some defaults
    before_validation { self.token = SecureRandom.uuid  if token.blank? }

    # Some methods for setting the billing & delivery addresses
    attr_accessor :save_addresses, :billing_address_id, :delivery_address_id

    def self.recover_order(params)
      p 'Inside her'
      p params.to_yaml
      email = params[:email_buyer] || params[:buyerEmail]
      customer = Shoppe::Customer.includes(:addresses).find_by(email: email)
      address = customer.addresses.first
      order = customer.orders.create(first_name: customer.first_name, last_name: customer.last_name, billing_address1: address.address1, billing_address3: address.address3, billing_address4: address.address4, billing_postcode: "xxxx", email_address: customer.email, phone_number: customer.phone, billing_country: Shoppe::Country.find(1))
      products = JSON.parse(params[:extra1])
      products.each do |product|
        order.order_items.add_item(Shoppe::Product.find(product["id"].to_i), product["q"].to_i)
      end
      logger.info "Recovering Order with id #{params[:reference_sale] || params[:referenceCode]}"
      order
    end

    # The order number
    #
    # @return [String] - the order number padded with at least 5 zeros
    def number
      id ? id.to_s.rjust(6, '0') : nil
    end

    # The length of time the customer spent building the order before submitting it to us.
    # The time from first item in basket to received.
    #
    # @return [Float] - the length of time
    def build_time
      return nil if received_at.blank?
      created_at - received_at
    end

    # The name of the customer in the format of "Company (First Last)" or if they don't have
    # company specified, just "First Last".
    #
    # @return [String]
    def customer_name
      company.blank? ? full_name : "#{company} (#{full_name})"
    end

    # The full name of the customer created by concatinting the first & last name
    #
    # @return [String]
    def full_name
      "#{first_name} #{last_name}"
    end

    def self.to_csv
      titulos = %w{Numero Cliente Estado Productos Valor-Total Fecha Guia}
      attributes = %w{number customer_name status order_items total received_at consignment_number}

      CSV.generate(headers: true) do |csv|
        csv << titulos
        all.each do |order|
          csv << attributes.map do |attr|
           if attr == 'order_items'
             result = order.order_items.map do |item|
               [item.quantity, item.ordered_item.full_name].join(' ')
             end
             result.join(' ')
           elsif attr == 'received_at'
             order.received_at.strftime("%B %-d, %Y")
           else
             order.send(attr) ? order.send(attr) : 'Sin asignar'
           end
          end
        end
      end
    end

    # Is this order empty? (i.e. doesn't have any items associated with it)
    #
    # @return [Boolean]
    def empty?
      order_items.empty?
    end

    # Does this order have items?
    #
    # @return [Boolean]
    def has_items?
      total_items > 0
    end

    # Return the number of items in the order?
    #
    # @return [Integer]
    def total_items
      order_items.inject(0) { |t, i| t + i.quantity }
    end

    def items_and_quantities
      order_items.map do |item|
        {id: item.ordered_item.id, q:item.quantity}
      end
    end

    def self.ransackable_attributes(_auth_object = nil)
      %w(id billing_postcode billing_address1 billing_address2 billing_address3 billing_address4 first_name last_name company email_address phone_number consignment_number status received_at) + _ransackers.keys
    end

    def self.ransackable_associations(_auth_object = nil)
      []
    end
  end
end
