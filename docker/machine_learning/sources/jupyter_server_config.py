import os

c = get_config()

c.ServerApp.root_dir = "/workspace"
c.IdentityProvider.token = os.environ.get("JUPYTER_TOKEN", "")
c.ServerApp.allow_origin = "https://ingpedro11.github.io"

# Cookies de sesión válidas dentro de un iframe de otro sitio
c.IdentityProvider.cookie_options = {"SameSite": "None", "Secure": True}

c.ServerApp.tornado_settings = {
    "headers": {
        "Content-Security-Policy": (
            "frame-ancestors 'self' "
            "https://ingpedro11.github.io "
            "http://localhost:7909"
        )
    },
    # Cookie _xsrf con las mismas opciones
    "xsrf_cookie_kwargs": {"samesite": "None", "secure": True},
}

c.ServerApp.disable_check_xsrf = True