from datetime import datetime

import requests
from django import template

register = template.Library()


@register.inclusion_tag("pages/tags/pypi_info.html")
def pypi_info(package_name):
    package_api_url = f"https://pypi.org/pypi/{package_name}/json"
    response = requests.get(package_api_url)

    if response.status_code != 200:
        return {
            "release": None,
        }

    package_info = response.json()
    date = datetime.strptime(
        package_info["releases"][package_info["info"]["version"]][0]["upload_time"],
        "%Y-%m-%dT%H:%M:%S",
    )

    ctx = {
        "release": package_info["info"]["version"],
        "pypi_url": package_info["info"]["project_url"],
        "home_page": package_info["info"]["home_page"],
        "release_date": datetime.strftime(date, "%d %b %Y"),
    }

    return ctx
