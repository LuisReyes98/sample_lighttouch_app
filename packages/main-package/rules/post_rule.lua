priority = 2
input_parameter = "request"
events_table = ["view_posts"]

request.method == "GET"
and
#request.path_segments == 1
and
request.path_segments[1] == "posts" -- /posts