Deface::Override.new(:virtual_path => "spree/admin/shared/_configuration_menu",
                     :insert_bottom => "[data-hook='admin_configurations_sidebar_menu']",
                     :name => "bronto_admin_configurations_menu",
                     :text => "<%= configurations_sidebar_menu_item Spree.t('bronto.lists_admin'), admin_bronto_lists_path %>",
                     :disabled => false)
