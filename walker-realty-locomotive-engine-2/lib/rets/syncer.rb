require_relative '../../app/models/singlefamily'
require_relative '../../app/models/rets_update'
require_relative '../../app/models/mls'
require 'logger'
require 'mongoid'
require 'pathname'

dump = false
ingest = false

dump = true if ARGV.include?("dump") 
ingest = true if ARGV.include?("ingest")

if !(dump || ingest)
	dump = true
	ingest = true
end

path = Pathname.new(File.dirname(__FILE__) + "/../../config/mongoid.yml").realpath.to_s

Mongoid.load!(path, :production)

# Setup a log file to rotate every 100M
logfile = Pathname.new(File.dirname(__FILE__) + "/mls_sync.log").realpath.to_s
$LOG = Logger.new(logfile, 0, 100 * 1024 * 1024)
$LOG.formatter = Logger::Formatter.new
$LOG.level = Logger::INFO

lookup_cache = {}

# Loop over all othe lookup tables and cache the values so that we save the value rather than the keys, which are useless
$LOG.debug "Caching Lookup Tables for Single Family Homes"
lookup_tables = SingleFamilyHome.lookup_tables()
lookup_tables.each do |attribute, info|
  lookup_cache[attribute] = MLS.get_lookup_values(SingleFamilyHome.resource, SingleFamilyHome.klass, attribute)
end

if dump
	begin
		last_update = RetsUpdate.desc(:created_at).first.created_at
		$LOG.info "Grabbing all Single Family Home updates since #{last_update}"
		count = MLS.dump_all_properties(SingleFamilyHome, lookup_cache, last_update)
	rescue
		$LOG.info "Grabbing all Single Family Homes in the database. A full backup has not been perfomed on this machine before"
		count = MLS.dump_all_properties(SingleFamilyHome, lookup_cache)
	end

	RetsUpdate.create(
		property_class: SingleFamilyHome.name,
		record_count: count
	)
	$LOG.info "Downloaded #{count} listings to harddisk"
end

if ingest
	begin
		$LOG.info "Ingesting all updates downloaded from last sync"
		MLS.load_properties(SingleFamilyHome, lookup_cache)
	rescue Exception => e
		$LOG.info "Load failed somehow: #{e.message}"
	end
end
