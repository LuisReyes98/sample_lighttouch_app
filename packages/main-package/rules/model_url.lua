priority = 1
input_parameter = "request"
events_table = ["home"]

request.method == "GET"
and
#request.path_segments == 2
and
request.path_segments[1] == "home"
and
models[request.path_segments[2]]