from django.db import models
from wagtail.admin.panels import FieldPanel
from wagtail.fields import StreamField
from wagtail.models import Page

from webapp.pages.blocks import BaseBlocks


class BasePage(Page):
    class Meta:
        abstract = True


class ArticleIndexPage(BasePage):
    subpage_types = ["pages.ArticlePage"]
    body = StreamField(
        BaseBlocks,
        blank=True,
        use_json_field=True,
    )
    content_panels = Page.content_panels + [
        FieldPanel("body"),
    ]

    def get_context(self, request):
        context = super().get_context(request)
        context["articles"] = (
            ArticlePage.objects.live().descendant_of(self).order_by("-date")
        )
        return context


class ArticlePage(BasePage):
    parent_page_types = ["pages.ArticleIndexPage"]
    body = StreamField(
        BaseBlocks,
        blank=True,
        use_json_field=True,
    )
    date = models.DateField("Article published date")
    excerpt = models.CharField(max_length=255, blank=True)

    content_panels = Page.content_panels + [
        FieldPanel("body"),
        FieldPanel("date"),
        FieldPanel("excerpt"),
    ]

    def get_latest_articles(self):
        return ArticlePage.objects.live().order_by("-date")[:3]

    def get_context(self, request):
        context = super().get_context(request)
        context["latest_articles"] = self.get_latest_articles()
        return context
