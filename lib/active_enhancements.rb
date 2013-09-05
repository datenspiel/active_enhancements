# -*- encoding : utf-8 -*-
module ActiveEnhancements
  
  def self.included(base)
    base.send(:extend, ClassMethods)
  end
  
  module Errors
    
    class HashNotEmptyError < StandardError; end
      
  end
  
  module ClassMethods
    
    def collectable(*attrs)
      raise ArgumentError, "No attributes given" if attrs.empty?
      self.all.collect do |n|
        [n.send(attrs.first), n.send(attrs.last)]
      end
    end
    
    def clear; all.each{|n| n.destroy}; end
    
    # resets the database table (includes an id reset)
    def revert
      delete_all
      connection.execute("ALTER TABLE #{table_name} AUTO_INCREMENT = 1")
      return true
    rescue 
       return false
    end
    
    def destroy_by_attributes(opt={})
      raise ActiveEnhancements::Errors::HashNotEmptyError if opt.empty?
      
      sql = "DELETE FROM #{table_name} WHERE "
      keys = []
      opt.each_pair do |key,value|
        keys << "#{key.to_s}='#{value.to_i}'"
      end
      if keys.size > 1
        sql += keys.join(" AND ")
      else
        sql += keys.to_s
      end
      connection.execute(sql)
      return true
    rescue
      return false
    end
    
    def find_or_create(params)
      begin
        return self.find(params[:id])
      rescue ActiveRecord::RecordNotFound => e
        attrs = {}
    
        # search for valid attributes in params
        self.column_names.map(&:to_sym).each do |attrib|
        # skip unknown columns, and the id field
        next if params[attrib].nil? || attrib == :id
          attrs[attrib] = params[attrib]
        end
    
        # call the appropriate ActiveRecord finder method
        found = self.send("find_by_#{attrs.keys.join('_and_')}", *attrs.values) if !attrs.empty?
    
        if found && !found.nil?
          return found
        else
          return self.create(params)
        end
      end
    end
    
  end
  
end
