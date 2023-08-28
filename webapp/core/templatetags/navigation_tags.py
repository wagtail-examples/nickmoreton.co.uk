from django import template

from webapp.core.models import Navigation

register = template.Library()


@register.inclusion_tag("core/tags/navigation.html", takes_context=True)
def get_navigation(context):
    navigation = Navigation.for_request(context["request"])
    ctx = {
        "request": context["request"],
        "main_menu": navigation.main_menu,
    }
    return ctx
