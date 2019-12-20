priority = 1
input_parameter = "request"
events_table = ["home"]

request.method == "GET"
and
#request.path_segments == 0
-- and
-- uuid.check(request.path_segments[1]) --example uuid /dasda238120398098419024dalk
-- or
-- models[request.path_segments[1] -- /model_name
-- request.headers["accept"]:match("text/html")
-- request.path_segments[1] == "path" -- /path
--request.query.code == '3213' --/?code="3213"
-- or
-- request.query.name --/?name="Any Value"