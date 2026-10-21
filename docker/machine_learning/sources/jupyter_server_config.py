c = get_config()

c.ServerApp.hide_file_browser = True
c.ServerApp.hide_toolbar = True
c.ServerApp.hide_menu = True

c.ServerApp.tornado_settings = {
    "headers": {
        "Content-Security-Policy": "frame-ancestors 'self' http://localhost:7909"
    }
}