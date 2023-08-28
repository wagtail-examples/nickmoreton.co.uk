from datetime import datetime

import requests
from django import template

register = template.Library()


@register.inclusion_tag("pages/tags/pypi_info.html", takes_context=True)
def pypi_info(context, package_name):
    package_api_url = f"https://pypi.org/pypi/{package_name}/json"
    response = requests.get(package_api_url)
    package_info = response.json()
    release = package_info["info"]["version"]
    pypi_url = package_info["info"]["project_url"]
    release_date = datetime.strptime(
        package_info["releases"][release][0]["upload_time"], "%Y-%m-%dT%H:%M:%S"
    )

    return {
        "release": release,
        "pypi_url": pypi_url,
        "release_date": release_date,
    }
