module Shoppe
  module OrdersHelper
    def total_boxes(orders)
      boxes = 0
      orders.each do |order|
        order.order_items.each {|order_item| boxes += order_item.quantity}
      end
      boxes
    end

    def total_price(orders)
      orders.reduce(0) {|sum, order| sum += order.total }
    end

    def total_weight(orders)
      weight = 0
      orders.each do |order|
        order.order_items.each do |order_item|
          weight += order_item.weight * order_item.quantity
        end
      end
      weight
    end
  end
end
