# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version
3.3.6

* Rails version
8.0.0.1

* System dependencies
Redis is installed and running

* Configuration
# Using native ruby 

* Database creation

Actually not needed, use only to implement a database cache
bundle exec rake db:create

* Database initialization
skip if not needed
bundle exec rake db:migrate

* How to run the test suite
bundle exec rake rspec

model spec to test validations
request spec to test 2 ways of mocking api data
system spec using capybara to test via ui using mocked api data
cache was tested manually in rails console

* Services (job queues, cache servers, search engines, etc.)
redis is running

* Deployment instructions

set environment_varliable WEATHER_API_KEY to value from the weatherapi.com weather service.
 You get a free key from weatherapi.com;
# chosen because I could see it had the data, the doc and tools were good, it was quickly understandable, commercials versions existed. They are doing hobbiest a real servie

On local
Start redis
Start rails server bundle exec rails s -p 2999
On browser localhost:2999
Enter 5 digit zipcode, create forecast button
Results shown for that zipcode including location,
temperature, and 5 day forecast in table : date, min_temp_f, max_temp_f, and condition,

DESIGN NOTES
Ok, so lets call a free api to get the needed wather data present it by zip code. weatherapi.com was chosen.
Quickly verified api worked with there was onsite tester see the payload. Reproduced from rails console.

Key question is how to cache. Thought of rails cache (memory, redis, memcached).
Decide on rails cache, first memory, then to redis. I have seen both in production.
At first I cached the api response, a very big payload. How many zip codes? Total possible is 41704.
That times pages of json, not good.
How many active in cache? How much is stored in entry. Let's just store the result needed for
display. Or, I could just store the forecast object to a database; with the timestamp, I could do a 
datebase read, refresh with api call if older than 30 minutes. 
This would be a database cache.

I chose the redis cache via rails cache as a reasonable start.
With thought of frequency of query over time against the rails service (the LOAD)
 the service times of the service api call, the redis cache, and the database as cache,
 a more thoughtful decision could be made. 
 How many entries would typically be active at one time.
the 

