event = ["view_posts"]
priority = 2
input_parameters = ["request"]

return {
    status = 200,
    headers = {
        ["content-type"] = "text/html",
    },
    body = render("post.html", {
        TITLE = settings.sitename,
    })
}