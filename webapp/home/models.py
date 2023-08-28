from wagtail.admin.panels import FieldPanel
from wagtail.fields import StreamField
from wagtail.models import Page

from webapp.pages.blocks import BaseBlocks
from webapp.pages.models import ArticlePage, PackagePage


class HomePage(Page):
    max_count = 1
    body = StreamField(
        BaseBlocks,
        blank=True,
        use_json_field=True,
    )

    content_panels = Page.content_panels + [
        FieldPanel("body"),
    ]

    def latest_article(self):
        return ArticlePage.objects.live().order_by("-date").first()

    def latest_package(self):
        return PackagePage.objects.live().order_by("-date").first()

    def get_context(self, request):
        context = super().get_context(request)
        context["latest_article"] = self.latest_article()
        context["latest_package"] = self.latest_package()
        return context
