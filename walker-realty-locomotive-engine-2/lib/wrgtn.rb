if Rails.env.development?
  load File.join(File.dirname(__FILE__), 'wrgtn', 'liquid.rb')
else
  require 'wrgtn/liquid'
end

module Wrgtn
end