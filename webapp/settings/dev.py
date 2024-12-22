from .base import *  # noqa

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = True

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = "django-insecure-1r93dd+db8)#&g_%2o5)78zh!#rop*eclqgv$y)my@k2p&ra*)"

# SECURITY WARNING: define the correct hosts in production!
ALLOWED_HOSTS = ["*"]

EMAIL_BACKEND = "django.core.mail.backends.console.EmailBackend"

CSRF_TRUSTED_ORIGINS = ["http://localhost:3000"]

try:
    from .local import *  # noqa
except ImportError:
    pass
