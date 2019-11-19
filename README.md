# Getting started with Torchbear , Speakeasy and lighttouch

## What is Torchbear ?

Torchbear is web framework build in rust, to create a general-purpose programming environment. Torchbear is the kernel of lighttouch.

## What is Speakeasy ?

Speakeasy is a concise and complete software stack meant for general purpose problem solving.

### Speakeasy syntax

Speakeasy works with the PUC-Rio interpreter, using  Lua for basic data structure and controls with additional functions fitting a broad range of use cases. And it is enhanced with  Torchbear's built-in modules , to which you can check a list of all of the included functions they have in the Torchbear's bindings documentation.

## What is Lighttouch ?

Lighttouch is a framework that makes complex application development simpler. It does this through broad use of component-oriented design intended to offer programmers a well-researched alternative to starting with a blank canvas

## Building your first app in lighttouch

although the core of lighttouch , Torchbear is build in rust , lighttouch apps are written in a simplier code syntax with lua.
Lighttouch is a framework that looks forwards to simplify the development of webpages, the front-end is handle as themes and the backend is handle as packages, both will be explain now.

## Packages

Lighttouch backend is handle in the form of Packages; packages are Lighttouch's main unit of addon functionality. They leverage event-driven, rule-based programming.

This basically means that packages have actions, events, and rules. Following a simple event driven interface

* the rules represent the url configuration , path name, valid atributes, and priority of check in comparison with other paths

* the actions represent all the logic needed for the corresponding url

* And the events of each package represent the connection between the rules and the actions, these are defined in the events.txt of the package.

### Events

Events are very simple. They get loaded into a global list by reading each package's `events.txt` file. They can be disabled in a `disabled_events.txt` file.

### Structure of the event driven code

each package of the project must contain a file `events.txt`  where all name of the events of the package will be defined each declared in a new line.
Like in this example:

```txt
get_document_form
request_document_html
request_document_edit_form
list_documents_html
list_subdocuments_html
```

### Packages Rules

in a package the rules represent the configuration for the url paths of an action
the format to create on consists in declaring  first `priority` , `input_parameter` and `events_table` , at the beginning of the file.

* `priority` is a number to implicitly declare the order in which the rules are check in case two or more rules have similar parameters, the one with the number closest to 1 will be the first one checked to be used.
This allows for identical url perform different when a parameter is send for example

* `input_parameter` name of the variable that is received as the request, should be set to ‘request’ unless a different name is necessary

* `events_table`
array of names of all the events  that correspond to this rule , this allows for a rule to execute more than one action when the url is called. Because when the rule is executed it will call all the actions that belong to the events declared in the events_table

#### Request URL configuration

to configure the url a series of rules are set with the use of logicals `and` and `or` to define the necessity of a rule or if it is optional. This makes the rules to have an if like syntax that if is true it will call the actions that correspond to the rule. The options that can be used to build an url are:

* `request.method` , it can be any [http method](https://developer.mozilla.org/es/docs/Web/HTTP/Methods) type; like “GET”, “POST”, “PUT”, “DELETE” , etc.

* `#request.path_segments` , number of path segments the url has, for example `/home/users` is 2 path segments

* `request.path_segments[n]` : is a string, where n is any number minor or equal to the amount of path segments, with this it can be specified exactly which name will have each segment of the url

* `request.headers["name"]:match("value")` , here name and value are any two strings that are checked in the header of the element when the request is made. Use example:

```lua
request.headers["accept"]:match("html")
```

* `models[request.path_segments[n]]`  , checks that the path segment at n (n being any number) belongs to a valid model name , models and their use will be explained below

* `uuid.check(request.path_segments[n])`  , checks that the path segment at n (n being any number) is valid uuid string , uuid being the identifier used by contentdb which will be explained below.

* `request.query.name`, `name` can be any string that belongs to a valid url param; this rule checks that among the send params there is one with the specified name.

Example of a valid lighttouch rule:

```lua
priority = 2
input_parameter = "request"
events_table = ["witness_html"]

request.method == "GET"
and
#request.path_segments == 0
and
request.query.witness
and
uuid.check(request.query.witness)
```

#### Package actions

the actions represent the logic that will be executed once the rules that corresponds to its event is called, at the beginning of the file the must always be the following parameters:

* `event` , is an array that should hold one element with the name of the event that it belongs to.

* `priority`, should be the same one as in the rules

* `input_parameters` is an array with the name of all the input parameters it will received , it should always have “request”.

Example of the parameters of an action:

```lua
event = ["issues_request_received"]
priority = 1
input_parameters = ["request"]
```

afterwards all the code and logic to be performed in this view is executed there must be a return. In the case that this action is one of many that where called by the same rule it may not have a return, but one of the called actions must have a return.

The return is a table that contains a header and a body , ready to be a json response.
In case of being a normal html view it must be scecified to `render` and html , which receives the route to the html in the current theme, and a table of variables to render in the html.

Example of action return of a html:

```lua
response = {
    headers = {
        ["content-type"] = "text/html",
    },
    body = render("index.html", {
        iname = name,
    })
}

return response
```

**Code modularity**
In lua to import or excecute code from differen files the keyword `require` is used. And the  path to the file is defined as they are packages dependencies, for example: we have the file `build.lua` in the following path  `packages/utils/build.lua` in order to add that code inside an actions file, it would need the following syntax: `require “packages.utils.build.”` to properly include the file.

## Themes and Style engine

Lighttouch apps handle the frontend by the use themes and tera templates

### Themes

The way lighttouch handles the front-end is by the use of a series of themes that are defined in the themes folder of the application.
The themes can be as complex as the whole layout of a page or as simple as singular html component that can be reused.
The themes are composed by a folder that contains the info.yaml file that contains the theme name and dependencies to other themes (parent themes), the html files that are treated as templates, css and any other folders or files that may be used to keep the code orgnaized

themes are automatically registered by lighttouch in the application, the application launches using a singular theme still themes can have as many parent themes as they may need.

#### Calling HTML

When and html element is call to be render from the back-end or is included in the template as such:  `{% include "component.html" %}` , lighttouch will automatically look for the template in the  current theme and if it is not found it would search for it in the parent themes iterating over them in the same order that they were declared.
Graphic example of the search:

* looking for the component `el.html` example:
|-- Current Theme :x:
| ---- Parent theme 1 :x:
| ------ Parent theme 2  :heavy_check_mark: `el.html` **found**
| -------- Parent theme 3  :heavy_exclamation_mark: **Never Reached**

it is important to know that the order of declaration of the parent theme matters when the app is call to include an html element , because if in different themes a file location and name repeats, lighttouch will use the first one it founds

#### Tera

Lighttouch uses The template language [Tera](https://tera.netlify.com/docs/templates/), to control the designing of the front-end, Tera allows to show variables , use filters for variable , create render conditionals, use of for methods, to include html elements and to allow that a template can extend form another template even if the template doesn't exist in the current theme and it belongs to a parent theme.

with this in consideration the front-end layout can be very organized by spliting each element in different template files and even split more complex elements into a separated theme to improve the re usability of the html.

The Tera template also allows to treat html as objects that contain blocks of content and that can extend from other html elements

##### Tera template Block

with the use of the blocks the re usability of html templates is very easy to achieve, in the following example it can be seen the base.html layout that other templates can extend from

```html
    <!DOCTYPE html>
    <html>
        <!-- grand grand parent -->
        <head>
            {% block head %}
            {% endblock head %}
            <title>
                {% block title %}
                {% endblock title %}
            </title>
        </head>
        <body>
            <div id="header">
                {% block header %}
                    <!-- Header -->
                {% endblock header %}
            </div>
            <div id="content">
                {% block content %}
                    <!-- Content of any page -->
                {% endblock content %}
            </div>
            <div id="footer">
                {% block footer %}
                    <!-- footer -->
                {% endblock footer %}
            </div>
        </body>  
    </html>
```

and then for a template to use would be in the following way:

```html
    {% extends "layouts/base.html" %}
    {% block content %}  
        {{ super() }}
        <div site_content id="page_content">
            Site Content

            Lorem Incididunt sunt excepteur esse in laboris.
            Laboris eiusmod mollit quis id nulla eu occaecat d
            olor Lorem do dolore aliqua exercitation anim.
            Est anim incididunt reprehenderit elit ex incididu
            nt ipsum enim veniam sunt anim irure.
            Irure do minim elit nulla sint.
        </div>
    {% endblock content %}
```
as you can see in this example there is the call to super inside the content block , this is call for the template to add any content that is in the content block of the parent template.

##### Tera template extension

the extension feature allows for the same layout to be used and only change the content within the layout the template extension must be done at the beginning of the file, and the syntax to extend from a file in the same theme it must be declared specifying the path to the file in the theme:

```tera
{% extends "chunks/modal.html" %}
```

also If you wish to extend from a template in the parent theme thats also possible by adding `^/` at the beginning of the path, performing a search for a template that is in the described location in one of the parent themes.

```tera
{% extends "^/chunks/modal.html" %}
```

##### including elements in the html

Using the keyword include:

```tera
  {% include "chunks/footer.html" %}
```

you can include in a templates all the contents of a different template to organize the code of the layouts more easily
also the include is not limited to html filesyou can include the contents of any file that you want as longs as the contents are readeable by html
for example you can include a css file to be added inside style tags in the header

```html
    <style type="text/css">
      {% include "css/styles.css" %}
    </style>
```

_style folder and files

to improve readability of an html with styles the styles are written in different css classes and then added to the html, still  in some cases we can end up with an html element that contains too many classes and is hard to read.

In order to improve html readability lighttouch uses the _style syntax which consist in using an unique name for the class group that wants to be used, a _style folder , a folder for the template with the template name template.html as the folder name, and the use of .txt files with the element tag and unique name, for example div main_page.txt , yes with the empty space, this .txt will contain the name of all the classes of the respective element in the html,  the classes can be separated by enter or spaces, lighttouch uses the _style syntax by matching the file exact name with an element in the html it that matches the name of the folder the file is contained at.
the use of this causes to have a very minimalist html that's easy to read, and all the css classes that have been declared in the files will will be automatically added to the html once it is rendered:

``` html
    <div centered_container >
        <a blue_button href="/?witness={{ id }}">
            Witness
        </a>
        <a blue_button href="/{{model}}/">
            Go to list
        </a>
        <a yellow_button href="/{{model}}/{{id}}/edit">
            Edit
        </a>
    </div>
```

in this example there are 3 _style identifiers `div centered_container`, `a blue_button`, `a yellow_button` each of this identifiers contains a file inside the template folder with all the css classes of the element, for this example in the previous html these are the files used:

* div centered_container.txt

    ```txt
    text-center
    px-4
    py-4
    ```

* a blue_button.txt

    ```txt
    bg-blue-500
    rounded-full
    py-2
    px-4
    hover:bg-blue-600
    hover:text-white
    ```

* a yellow_button.txt

    ```txt
    bg-yellow-500
    rounded-full
    py-2
    px-4
    hover:bg-yellow-600
    hover:text-white
    ```

this improves the readability of the html and in order to keep a better organization of the styles.

The whole project layout would look like the following

-root project folder
    -themes
        -main-theme
            index.html
            -_style
                -index.html
                    div container.txt

## Settings file lighttouch.scl

the `lighttouch.scl` file is configuration file where settings are defined using scl ( [a simpl configuration language](https://github.com/foundpatterns/scl) ) , some are obligatory like: `theme` , `log_level` , `sitename`.

```scl
    theme = "main theme name",
    log_level = "trace",  # log level for development
    sitename = "name of the site",
```

any other setting value is completely optional and depends what you want to do, in here you can defined any secret key or api codes that your app uses to avoid having them in any place that could exposed to the user.

Also a value can be set to include another .scl file to load the information as fields in that setting variable.

Example of a  `lighttouch.scl` file:

```scl
    settings = {
        theme = "found-patterns-theme",
        log_level = "trace",
        sitename = "Found Patterns Studio",
        slideshow = "c800a360-d198-4a87-877e-b353f7dd0a9d",
        chat = include "chat.scl",
    }
```

chat.scl contents:

```scl
    header_title = "My Chat"

    header_image = "https://avatars0.githubusercontent.com/u/43634206?s=200&v=4"
```

the values set in settings can be accessed in the packages code with the syntax `settings.name_of_the_property` .  Making setting have a behavior of a key word defined lua table , also known as a dictionary in other programming languages.

## Machu Pichu dependency manager

Machu pichu is dependency manager used by torchbear in order to have better control of the dependencies in a project.
The configuration is established in the `manifest.scl` file which is at the root of the project.

The file has the imports dict where the name of the packages is define and where they will be downloaded.

Also bellow for each package an url must be defined to where the project will be fetch, it should be an url to a Git repository where the package is stored.

Example of a `manifest.scl` file

```scl
    imports = {
        send-file-package = "packages/send-file-package",
        lighttouch-html-interface = "packages/lighttouch-html-interface",
        lighttouch-json-interface = "packages/lighttouch-json-interface",
    }


    send-file-package = {
        url = "https://github.com/lighttouch-packages/send-file.git",
    }

    lighttouch-html-interface = {
        url = "https://github.com/lighttouch-packages/html-interface.git",
    }

    lighttouch-json-interface = {
        url = "https://github.com/lighttouch-packages/json-interface.git",
    }
```

once the file is ready run the command `mp unpack` and machu pichu will automatically donwload the packages and place them in their corresponding folder.
To read further about the **machu pichu** package manager you can check the repository [machu pichu](https://github.com/foundpatterns/machu-picchu)

Note: is important to know that the dependencies declared in the manifest.scl are treated as such and are assumed that they wont go through changes or will be edited by the use in anyway.
Thats why running the command `mp unpack` will override any changes that were done to the files in that where added this way with machu pichu.
So if you are working in development with the project and also developing the dependencies is recommended that you manually add the dependencies where you need it so you can edit it without the risk of your changes being overwritten.

## ContentDB database and models

Torchbear comes with the database ContentDB which is a document store database, it is NoSQL, these means all the entries are files that are saved within the project folder and use uuid to identify each entry.

ContentDB has all the functionalities needed from file searching to filtering, and even declaring refences to other documents.

### Models

Also lighttouch allows the use of models, inside the packages that are a definition of an object in a .scl file and they are stored in the folder `models` of any package.
To use the models is need to implement the packages of `html-interface` and `json-interface` allowing to create documents that have the fields declared in the models .scl file.
An example of models file is the following `message.scl`

```scl
    description="Message"
    fields={
        title={
            required=true,
            type="string",
        },
    }
```

### Built in packages for models handling

in order to use a packages models there must be implemented to light touch packages

* [The html interface](https://github.com/lighttouch-packages/html-interface)  which is a ready to be used html UI for the CRUD of a model, this package depends on the `json-interface` package

* [the json interface](https://github.com/lighttouch-packages/json-interface) , the json interface provides a ready to be used api to create and request for documents.

Once the model file is created it is ready to used, to interact with ui it is show in the url path with the same name of the model in the case of the example above with the `message` model the url  path in the app is `/message`.

### Built in themes

* **base-theme**: even though the use of base theme is totally optional and you can develop your own custom views for the handling the models views, [base-theme](https://github.com/lighttouch-themes/base-theme)  already comes with a ready to be used interface to the handling of models , all you need to do is the correct setup (explained in the following segment) .

### Setting up  html interface in your project main theme

html-interface package UI is already implemented in the base-theme of lighttouch to use you only need to create a folder called chunks in your project and in there create the following the corresponding files to handle the models and include the views from base-theme, (Note: your theme must have base theme as parent), the files to be created and the view they need to add are the following:

* `show_document.html` for the view of a document , to add base-theme view add into the file the following:

    ```tera
    {% include "chunks/show_document/show_document_content.html" %}
    ```

* `model_form.html` for the creation and update of a document, to add base-theme view add into the file the following:

    ```tera
    {% include "chunks/model_form/model_form_content.html" %}
    ```

* `list_documents.html` for listing all the corresponding documents, to add base-theme view add into the file the following:

    ```tera
    {% include "chunks/list_document/list_documents_content.html" %}
    ```

and that's it. all that is left is to create is model and to access its interface go to the url of the same name of the model file, example:

the model file `project.scl` will respond to the url `www.my_root_url.lorem/project`  from the root URL , (`localhost:3000/project` in development).

#### referencing a document

html-interface supports for a document model to reference another, to define it in the model it just needs a field with the same name as the model file to be referenced this field should be type uuid.

Example:
`comment` model references `post` model to this a field must be added in the comment.scl model file

```scl
    description = "Comment"
        fields = {
        title = {
            type = "string"
        },
        body = {
            type = "string"
        },
        post = {
            type = "uuid"
        }
    }
```

### Custom use of contentdb and the models

Lighttouch has build in packages and themes that use contentdb and models, but also this functionalities can be used to build more custom behavior with all the function that contentdb possesses.

Concepts:
Stores: Contentdb documents are stored in the “content” folder of the project, and inside the “content” folder are the “store” folders, these are folders that have an uuid for name, inside the store folder are saved all the documents of contentdb.
By default each new app generates a new store identifier and works with one store folder altough you can work with multiple store folders.

ContentDB
Among the more basic functionalities of contentdb one can name:

* `contentdb.walk_documents (_store_id, fn)` receives the uuid of the document store if nil it will walk all the stores and a callback function that will be called with each document in the store.
The function must have the in the following order:
uuid of the file
fields of the file
body of the file (is an abstraction of the field body in the file)
store same store as the search was call if a store was given

    ```lua
    function (file_uuid, fields, body, store)
    end
    ```

Inside this function it can declared all the logic and conditionals to work the documents in the store from search to filtering etc…

*`contentdb.read_document(document_uuid)` receives an uuid and returns the document it belongs to.

*`contentdb.write_file (store_id, file_uuid, fields, body_param)` writes a new document with the given attributes it will be saved in the stored defined with the uuid given , it will save with all the fields this being a simple key table with only values , fields can not have subtables, and body param is the content of the body in the document

*Note ContentDB currently doesnt have a build in delete document although lighttouch has it, consider doing a PR with those changes

Model
the model interface is easy to use and has two main uses in actions and in rules:

* Action use: inside the code exists the global variable `models` that is key table that contains all of the registered models in the app so callling `models[‘model-name’]` will give the definition of the model from the model.scl (fields, description, etc...)

* Rule use: using `models[request.path_segments[1]]` will check if the first path segment belongs to a model name, using this logic you can build url that check if they have a valid model name.

## API request

executing api request to any rest or authenticated api service is easy with the use of the Lighttouch HTTP Interface

ligttouch uses torchbear http module to execute HTTP methods to a server
the syntax to execute them in the back-end is the following

```lua
    local response = send_request({
        uri = 'https://jsonplaceholder.typicode.com/todos/1',
        method="get",
        headers={
            ["content-type"]="application/json",
        },
    })
```

this simple way one can execute all types of requests to a server
