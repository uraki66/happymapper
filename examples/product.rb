dir = File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
require File.join(dir, 'happymapper')
require 'pp'

file_names = %w{ default no single }
file_contents = file_names.collect { |fn| File.read(dir + "/../spec/fixtures/product_#{fn}_namespace.xml") }

class Feature
  include HappyMapper

  element :name, String, :tag => '.'
end

class FeatureBullet
  include HappyMapper

  tag 'features_bullets'
  has_many :features, Feature
  element :bug, String
end

class Product
  include HappyMapper

  element :title, String
  has_one :features_bullets, FeatureBullet
end

file_names.each_with_index do |fn, i| 
  puts "Product test for #{fn} namespace document follows:\n\n"
  pp Product.parse(file_contents[i])
  puts "\n"
end