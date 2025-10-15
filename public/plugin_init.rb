require_relative '../umd_lib_environment_banner_helper'

# insert our custom cite_url_and_timestamp method into the Record class
# to display the EAD location (if present); falls back to the ASpace PUI URL
Rails.application.config.after_initialize do
  class ArchivalObject
    attr_reader :cite

    def umd_citation
      cite = note('prefercite')
      if !cite.blank?
        cite = strip_mixed_content(cite['note_text'])
      else
        cite = strip_mixed_content(display_string)
        cite += identifier.blank? ? '' : ", #{identifier}"
        cite += if container_display.blank? || container_display.length > 5
                  '.'
                else
                  @citation_container_display ||= parse_container_display(:citation => true).join('; ')
                  ", #{@citation_container_display}."
                end

        if resolved_resource
          ttl = resolved_resource.dig('title')
          cite += " #{strip_mixed_content(ttl)}, #{resource_identifier}."
        end
        unless repository_information['top']['name'].blank?
          cite += " #{ repository_information['top']['name']}, University of Maryland Libraries."
        end
      end
    end

    def cite_item
      HTMLEntities.new.decode("#{umd_citation}")
    end

    def cite_item_description
      HTMLEntities.new.decode("#{umd_citation}   #{cite_url_and_timestamp}.")
    end
  end

  Record.class_eval do
    def cite_url_and_timestamp
      url = @json['ead_location'] || "#{AppConfig[:public_proxy_url].sub(/^\//, '')}#{uri}"
      "#{url}  #{I18n.t('accessed')}  #{Time.now.strftime("%B %d, %Y")} foobarbaz"
    end
  end
end

# Addition to navigation main menu
Plugins::add_menu_item('/', 'brand.home', 0)
Plugins::add_menu_item('https://www.lib.umd.edu/help-using-archival-collections', 'help_tab')

# URL for website feedback
AppConfig[:website_feedback_url] = 'https://libumd.wufoo.com/forms/rb2fewh0i9d7bc/'
