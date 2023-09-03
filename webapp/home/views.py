from django.views.generic import TemplateView


class KitchenSinkView(TemplateView):
    template_name = "home/kitchen_sink.html"
