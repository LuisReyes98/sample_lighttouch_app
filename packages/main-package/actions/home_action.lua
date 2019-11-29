event = ["home"]
priority = 1
input_parameters = ["request"]

require "packages.main-package.test.test"

test.click()

return {
    status = 200,
    headers = {
        ["content-type"] = "text/html",
    },
    body = render("index.html", {
        message = "Hello world",
    })
}