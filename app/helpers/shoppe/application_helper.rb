module Shoppe
  module ApplicationHelper
    def navigation_manager_link(item)
      link_to item.description, item.url(self), item.link_options.merge(class: item.active?(self) ? 'active' : 'inactive')
    end

    def status_tag(status)
      content_tag :span, t("shoppe.orders.statuses.#{status}"), class: "status-tag #{status}"
    end

    def attachment_preview(attachment, options = {})
      if attachment.present? && attachment.token.present?
        ''.tap do |s|
          style = if attachment.image?
                    "style='background-image:url(#{attachment.file.thumb.url})'"
                  else
                    ''
          end
          s << "<div class='attachmentPreview #{attachment.image? ? 'image' : 'doc'}'>"
          s << "<div class='imgContainer'><div class='img' #{style}></div></div>"
          s << "<div class='desc'>"
          s << "<span class='filename'><a href='#{attachment.file.url}'>#{attachment.file_name}</a></span>"
          s << "<span class='delete'>"
          s << link_to(t('helpers.attachment_preview.delete', default: 'Delete this file?'), attachment_path(attachment.token), method: :delete, data: { confirm: t('helpers.attachment_preview.delete_confirm', default: 'Are you sure you wish to remove this attachment?') })
          s << '</span>'
          s << '</div>'
          s << '</div>'
        end.html_safe
      elsif !options[:hide_if_blank]
        "<div class='attachmentPreview'><div class='imgContainer'><div class='img none'></div></div><div class='desc none'>#{t('helpers.attachment_preview.no_attachment')},</div></div>".html_safe
      end
    end

    def settings_label(field)
      "<label for='settings_#{field}'>#{t("shoppe.settings.labels.#{field}")}</label>".html_safe
    end

    def settings_field(field, options = {})
      default = I18n.t('shoppe.settings.defaults')[field.to_sym]
      value = (params[:settings] && params[:settings][field]) || Shoppe.settings[field.to_s]
      type = I18n.t('shoppe.settings.types')[field.to_sym] || 'string'
      case type
      when 'boolean'
        ''.tap do |s|
          value = default if value.blank?
          s << "<div class='radios'>"
          s << radio_button_tag("settings[#{field}]", 'true', value == true, id: "settings_#{field}_true")
          s << label_tag("settings_#{field}_true", t("shoppe.settings.options.#{field}.affirmative", default: 'Yes'))
          s << radio_button_tag("settings[#{field}]", 'false', value == false, id: "settings_#{field}_false")
          s << label_tag("settings_#{field}_false", t("shoppe.settings.options.#{field}.negative", default: 'No'))
          s << '</div>'
        end.html_safe
      else
        text_field_tag "settings[#{field}]", value, options.merge(placeholder: default, class: 'text')
      end
    end

    def page_entries_info(collection, options = {})
      collection_name = options[:collection_name] || (collection.empty?? 'entry' : collection.first.class.name.underscore.sub('_', ' '))

      if collection.num_pages < 2
        case collection.size
        when 0; info = "No #{collection_name.pluralize} found"
        when 1; info = "Displaying <strong>1</strong> #{collection_name}"
        else;   info = "Displaying <strong>all #{collection.size}</strong> #{collection_name.pluralize}"
        end
      else
        info = %{Displaying #{collection_name.pluralize} <strong>%d&ndash;%d</strong> of <strong>%d</strong> in total}% [
          collection.offset_value + 1,
          collection.offset_value + collection.length,
          collection.total_count
        ]
      end
      info.html_safe
    end

    def total_boxes(orders)
      boxes = 0
      orders.size.times do |i|
        orders[i].order_items.size.times do |j|
          boxes += orders[i].order_items[j].quantity
        end
      end
      boxes
    end

    def total_price(orders)
      price = 0
      orders.size.times do |i|
        price += orders[i].total
      end
      price
    end

    def total_weight(orders)
      weight = 0
      orders.size.times do |i|
        orders[i].order_items.size.times do |j|
          weight += orders[i].order_items[j].weight * orders[i].order_items[j].quantity
        end
      end
      weight
    end
  end
end
