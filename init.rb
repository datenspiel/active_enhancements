# -*- encoding : utf-8 -*-
require File.join(File.dirname(__FILE__), "lib", "active_enhancements")

ActiveRecord::Base.send(:include, ActiveEnhancements)
