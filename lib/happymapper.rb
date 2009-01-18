dir = File.dirname(__FILE__)
$:.unshift(dir) unless $:.include?(dir) || $:.include?(File.expand_path(dir))

require 'date'
require 'time'
require 'rubygems'

gem 'libxml-ruby', '>= 0.9.7'
require 'xml'
require 'libxml_ext/libxml_helper'


class Boolean; end

module HappyMapper
  
  def self.included(base)
    base.instance_variable_set("@attributes", {})
    base.instance_variable_set("@elements", {})
    base.extend ClassMethods
  end
  
  module ClassMethods
    def attribute(name, type, options={})
      attribute = Attribute.new(name, type, options)
      @attributes[to_s] ||= []
      @attributes[to_s] << attribute
      create_accessor(attribute.name)
    end
    
    def attributes
      @attributes[to_s] || []
    end
    
    def element(name, type, options={})
      element = Element.new(name, type, options)
      @elements[to_s] ||= []
      @elements[to_s] << element
      create_accessor(element.name)
    end
    
    def elements
      @elements[to_s] || []
    end
    
    def has_one(name, type, options={})
      element name, type, {:single => true}.merge(options)
    end
    
    def has_many(name, type, options={})
      element name, type, {:single => false}.merge(options)
    end
    
    def tag(new_tag_name)
      @tag_name = new_tag_name.to_s
    end
    
    def get_tag_name
      @tag_name ||= to_s.downcase
    end
    
    def parse(xml, o={})
      options = {
        :single => false,
        :use_default_namespace => false,
        :use_slash => nil,
      }.merge(o)
      
      doc = xml.is_a?(LibXML::XML::Node) ? xml : xml.to_libxml_doc
      
      node = doc.respond_to?(:root) ? doc.root : doc
      
      # turn off ':use_default_namespace' option if doc doesn't have a default namespace
      if options[:use_default_namespace] && node.namespaces.default.nil? 
        warn ":use_default_namespace specified but XML has no default namespace, option ignored"
        options[:use_default_namespace] = namespace = nil 
      end

      # if doc has a default namespace, turn on ':use_default_namespace' & set default_prefix for LibXML
      unless node.namespaces.default.nil?
        options[:use_default_namespace] = true 
        namespace = "default_ns:" 
        node.namespaces.default_prefix = namespace.chop
        warn "Default XML namespace present -- results are unpredictable" 
      end

      # if not using default namespace, get our namespace prefix (if we have one) (thanks to LibXML)
      if node.namespaces.to_a.size > 0 && namespace.nil? && !node.namespaces.namespace.nil?
        namespace = node.namespaces.namespace.prefix + ":" 
      end
      
      nodes = if namespace
        node = doc.respond_to?(:root) ? doc.root : doc
        node.find("#{options[:use_slash]}#{namespace}#{get_tag_name}")
      else
        doc.find("//#{get_tag_name}")
      end

      collection = create_collection(nodes, namespace)
      
      # per http://libxml.rubyforge.org/rdoc/classes/LibXML/XML/Document.html#M000354
      nodes = nil
      GC.start
      
      options[:single] ? collection.first : collection
    end
    
    private
      def create_collection(nodes, namespace=nil)
        nodes.inject([]) do |acc, el|
          obj = new
          attributes.each { |attr| obj.send("#{attr.name}=", attr.from_xml_node(el)) }
          elements.each   { |elem| obj.send("#{elem.name}=", elem.from_xml_node(el, namespace)) }
          acc << obj
        end
      end
      
      def create_getter(name)
        class_eval <<-EOS, __FILE__, __LINE__
          def #{name}
            @#{name}
          end
        EOS
      end

      def create_setter(name)
        class_eval <<-EOS, __FILE__, __LINE__
          def #{name}=(value)
            @#{name} = value
          end
        EOS
      end

      def create_accessor(name)
        create_getter(name)
        create_setter(name)
      end
  end
end

require 'happymapper/item'
require 'happymapper/attribute'
require 'happymapper/element'
