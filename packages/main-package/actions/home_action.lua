event = ["home"]
priority = 1
input_parameters = ["request"]

return {
    status = 200,
    headers = {
        ["content-type"] = "text/html",
    },
    body = render("index.html", {
        message = "Hello world"
    })
}