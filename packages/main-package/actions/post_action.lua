event = ["view_posts"]
priority = 2
input_parameters = ["request"]

require "packages.main-package.mytools.base"
require "packages.main-package.mytools.add"

local val = mytools.add(2,4)

log.debug(val) -- 6

return {
    status = 200,
    headers = {
        ["content-type"] = "text/html",
    },
    body = render("post.html", {
        TITLE = settings.sitename,
    })
}