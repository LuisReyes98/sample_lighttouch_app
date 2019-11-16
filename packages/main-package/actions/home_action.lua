event = ["home"]
priority = 1
input_parameters = ["request"]


local model = models['project']

log.debug(json.from_table(model))

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