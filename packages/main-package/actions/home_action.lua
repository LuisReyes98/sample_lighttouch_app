event = ["home"]
priority = 1
input_parameters = ["request"]


local model = models['project']

-- log.debug(json.from_table(model)) -- check the console to see the value

-- http request
local response = send_request({
    uri = 'http://ron-swanson-quotes.herokuapp.com/v2/quotes',
    method="get",
    headers={
        ["content-type"]="application/json",
    },
})

log.debug(json.from_table(response.body)) -- check the console to see the value


return {
    status = 200,
    headers = {
        ["content-type"] = "text/html",
    },
    body = render("index.html", {
        message = "Hello world",
        TITLE = "Home",
        complement = settings.complement
    })
}