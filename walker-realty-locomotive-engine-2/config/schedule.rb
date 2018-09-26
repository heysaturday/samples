# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
every 1.days do
  runner "SearchController.cache_areas"
end

every 25.minutes do
   runner "CacheReloader.reload"
end

# Learn more: http://github.com/javan/whenever
