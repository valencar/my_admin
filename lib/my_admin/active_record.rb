require "my_admin/model_configuration"

module ActiveRecord
  class Base
    attr_accessor :my_admin_user
  end
end

module MyAdmin
  module ActiveRecordScopes

    def self.included(base)
      base.class_eval do
        def self.my_admin_order(params)
          if params[:order_by].present? and params[:order].present?
            order("#{params[:order_by]} #{params[:order]}")
          else
            where("")
          end
        end

        def self.my_admin_filter(model, field, params)
          if params[field].present? and !params[field].blank?
            where("#{model.table_name}.#{field} like ?", "%#{params[field]}%")
          else
            where("")
          end
        end

        def self.my_admin_filter_type_integer(model, field, params)
          if params[field].present? and !params[field].blank?
            where("#{model.table_name}.#{field} = ?", params[field])
          else
            where("")
          end
        end

        def self.my_admin_filter_type_belongs_to(model, field, params)
          if params["#{field.to_s.singularize}_id"].present? and params["#{field.to_s.singularize}_id"].to_i > 0
            where("#{model.table_name}.#{field.to_s.singularize}_id" => params["#{field.to_s.singularize}_id"].to_i)
          else
            where("")
          end
        end

        def self.my_admin_filter_type_boolean(model, field, params)
          if params[field].present? and !params[field].blank?
            where("#{model.table_name}.#{field}" => (params[field] == "true"))
          else
            where("")
          end
        end

        def self.my_admin_filter_type_date(model, field, params)
          if params[field].present? and !params[field].blank?
            where("#{model.table_name}.#{field} = :date", {:date => (params[field].to_date rescue nil)})
          else
            where("")
          end
        end

        def self.my_admin_filter_type_date_between(model, field, params)
          field_name_from = "#{field}_from"
          field_name_to = "#{field}_to"

          condition = ""
          if params[field_name_from].present? and !params[field_name_from].blank?
            condition += "#{model.table_name}.#{field} >= :date_from"
          end

          if params[field_name_to].present? and !params[field_name_to].blank?
            condition += " and " unless condition.blank?
            condition += "#{model.table_name}.#{field} <= :date_to"
          end

          where(condition, { :date_from => ( params[field_name_from].to_time.beginning_of_day rescue nil ), :date_to => ( params[field_name_to].to_time.end_of_day rescue nil ) })
        end


        def self.my_admin_filter_type_integer_between(model, field, params)
          field_name_from = "#{field}_from"
          field_name_to = "#{field}_to"

          field_value_from = params[field_name_from].to_i unless params[field_name_from].blank?
          field_value_to = params[field_name_to].to_i unless params[field_name_to].blank?

          condition = ""
          unless field_value_from.nil?
            condition += "#{model.table_name}.#{field} >= :integer_from"
          end

          unless field_value_to.nil?
            condition += " and " unless condition.blank?
            condition += "#{model.table_name}.#{field} <= :integer_to"
          end

          where(condition, { :integer_from => field_value_from, :integer_to => field_value_to })
        end

      end 
      
    end
    
  end
end

module MyAdmin
  module ActiveRecord
    
    def config_my_admin
      yield @configuration ||= MyAdmin::ModelConfiguration.new(self)
    end
    
    def my_admin
      @configuration ||= MyAdmin::ModelConfiguration.new(self)
    end
    
    def title_plural
      begin
        I18n.t!("activerecord.models.plural.#{i18n}")
      rescue
        I18n.t!("activerecord.models.#{i18n_plural}") rescue model_titleize.pluralize
      end
    end
    
    def title
      I18n.t!("activerecord.models.#{i18n}") rescue model_titleize
    end
    
    def tableize
      name.tableize.gsub(%r{/}, '_')
    end
    
    def titleize
      name.titleize.gsub(%r{/}, ' ')
    end
    
    def underscore
      name.underscore.gsub(%r{/}, '_')
    end
    
    def i18n
      name.underscore.gsub(%r{/}, '.')
    end
    
    def i18n_plural
      name.underscore.pluralize.gsub(%r{/}, '.')
    end
    
    def model_tableize
      name.tableize.split('/').last
    end
    
    def model_titleize
      name.titleize.split('/').last
    end
    
    def model_underscore
      name.underscore.split('/').last
    end
    
  end
end

ActiveRecord::Base.send(:extend, MyAdmin::ActiveRecord)
ActiveRecord::Base.send(:include, MyAdmin::ActiveRecordScopes)