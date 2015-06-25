local json = require 'dkjson'
local http = require 'socket.http'

local blog_name = ...

-- demo key from tumblr api docs
local api_key = 'fuiKNFp9vQFvjLNvx4sUwti4Yb5yGutBN4Xh10LXZhhRKjWlV4'
blog_name = blog_name or 'southp-ole.tumblr.com'
local tumblr_api_url = 'api.tumblr.com/v2/blog/'

local api_query = 'http://' .. tumblr_api_url .. blog_name .. '/posts/photo?' ..
	'api_key=' .. api_key

local function get_res_table(url)
	local res_json = http.request(url)
	local res = json.decode(res_json)
	return res
end

local function write_file(data, name)
	local imagefile = io.open(name, "w")
	imagefile:write(data)
	imagefile:close()
end

local function get_file_extension(url)
  return url:match("^.+(%..+)$")
end

local function mkdir(dir)
	f = assert(io.popen('mkdir ' .. dir))
	return f
end

mkdir(blog_name)

local res = get_res_table(api_query .. '&limit=1')

local total_photo_posts = res.response.total_posts
print(total_photo_posts)

local limit = 20
local loop_count = total_photo_posts / limit

local progress = 0
local prev_progress = 0
for i=1, loop_count do
	
	local res = get_res_table(api_query .. '&limit=' .. limit ..
		'&offset=' .. (i - 1) * limit)
	for a, k in ipairs(res.response.posts) do
		for j, l in ipairs(k.photos) do
				local ext = get_file_extension(l.original_size.url)
				local data = http.request(l.original_size.url)
				write_file(data, blog_name .. '/' .. k.id .. j .. ext)
				progress = ((i - 1) * limit + a) / total_photo_posts * 100
		end
	end
	if progress > prev_progress + 10 then
		print(math.floor(progress) .. '%')
		prev_progress = progress
	end
end

