base_dir = File.expand_path(File.join(File.dirname(__FILE__), '..'))
$LOAD_PATH.unshift(File.join(base_dir, 'lib'))
require 'grpc'
require 'pp'
require 'phone_services_pb'
require 'phone_pb'

credentials = GRPC::Core::ChannelCredentials.new(
  File.read(File.join(base_dir, 'certs/NextHotelSolutions_CA.crt')),
  File.read(File.join(base_dir, 'certs/service.key')),
  File.read(File.join(base_dir, 'certs/service.crt'))
)

stub = Phone::Phone::Stub.new('services.nexthotelsales.com:8443', credentials)
response = stub.get_hotel_dids(Phone::Empty.new)

pp response
