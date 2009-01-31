dir = File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
require File.join(dir, 'happymapper')
require 'pp'

file_contents = File.read(dir + '/../spec/fixtures/fedex.xml')

module FedEx
  class Address
    include HappyMapper
    
    tag 'Address'
    element :city, String, :tag => 'City'
    element :state, String, :tag => 'StateOrProvinceCode'
    element :zip, String, :tag => 'PostalCode'
    element :countrycode, String, :tag => 'CountryCode'
    element :residential, Boolean, :tag => 'Residential'
  end
  
  class Event
    include HappyMapper
    
    tag 'Events'
    element :timestamp, String, :tag => 'Timestamp'
    element :eventtype, String, :tag => 'EventType'
    element :eventdescription, String, :tag => 'EventDescription'
    has_one :address, Address
  end
  
  class PackageWeight
    include HappyMapper
    
    tag 'PackageWeight'
    element :units, String, :tag => 'Units'
    element :value, Integer, :tag => 'Value'
  end
  
  class TrackDetails
    include HappyMapper
    
    tag 'TrackDetails'
    element   :tracking_number, String, :tag => 'TrackingNumber'
    element   :status_code, String, :tag => 'StatusCode'
    element   :status_desc, String, :tag => 'StatusDescription'
    element   :carrier_code, String, :tag => 'CarrierCode'
    element   :service_info, String, :tag => 'ServiceInfo'
    has_one   :weight, PackageWeight, :tag => 'PackageWeight'
    element   :est_delivery,  String, :tag => 'EstimatedDeliveryTimestamp'
    has_many  :events, Event
  end 
    
  class Notification
    include HappyMapper
    
    tag 'Notifications'
    element :severity, String, :tag => 'Severity'
    element :source, String, :tag => 'Source'
    element :code, Integer, :tag => 'Code'
    element :message, String, :tag => 'Message'
    element :localized_message, String, :tag => 'LocalizedMessage'
  end
  
  class TransactionDetail
    include HappyMapper
    
    tag 'TransactionDetail'

    element :cust_tran_id, String, :tag => 'CustomerTransactionId'
  end
  
  class TrackReply
    include HappyMapper
  
    tag 'TrackReply'
    element   :highest_severity, String, :tag => 'HighestSeverity'
    has_many  :notifications, Notification, :tag => 'Notifications'
    has_one   :tran_detail, TransactionDetail, :tab => 'TransactionDetail'
    element   :more_data, Boolean, :tag => 'MoreData'
    has_many  :trackdetails, TrackDetails, :tag => 'TrackDetails'
  end
end

pp FedEx::TrackReply.parse(file_contents)
