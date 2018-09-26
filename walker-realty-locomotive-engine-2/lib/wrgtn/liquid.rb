require 'locomotive/liquid/drops/base'

%w{. tags drops filters}.each do |dir|
  Dir[File.join(File.dirname(__FILE__), 'liquid', dir, '*.rb')].each do |lib|
    if Rails.env.development?
      load lib
    else
      require lib
    end
  end
end
