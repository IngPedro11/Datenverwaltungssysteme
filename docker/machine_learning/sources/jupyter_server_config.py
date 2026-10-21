c = get_config()

# --- Netz ---
c.ServerApp.ip = "0.0.0.0"
c.ServerApp.port = 8888
c.ServerApp.open_browser = False
c.ServerApp.allow_root = True

# --- Access ---
c.ServerApp.token = "machine_learning123"
c.ServerApp.root_dir = "/home/jovyan/work"

# --- erlauben iframe in githubpages ---
c.ServerApp.tornado_settings = {
    "headers": {
        "Content-Security-Policy": (
            "frame-ancestors 'self' "
            "https://ingpedro11.github.io "
            "http://localhost:7909"
        )
    },
    # Cookies 
    "cookie_options": {"SameSite": "None", "Secure": True},
}


c.ServerApp.disable_check_xsrf = True


c.ServerApp.allow_origin = "https://ingpedro11.github.io"