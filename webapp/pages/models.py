from django.db import models
from wagtail.admin.panels import FieldPanel, MultiFieldPanel
from wagtail.fields import StreamField
from wagtail.models import Page

from webapp.pages.blocks import BaseBlocks


# ABSTRACT MODELS
class BasePage(Page):
    class Meta:
        abstract = True


# ARTICLE MODELS
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


class ArticlePageBase(BasePage):
    body = StreamField(
        BaseBlocks,
        blank=True,
        use_json_field=True,
    )
    excerpt = models.CharField(max_length=255, blank=True)

    class Meta:
        abstract = True

    def get_latest_articles(self):
        articles = ArticlePage.objects.live().order_by("-date").exclude(id=self.id)
        return articles[:3]

    def get_context(self, request):
        context = super().get_context(request)
        context["latest_articles"] = self.get_latest_articles()
        return context

    def get_chapters(self):
        chapters = self.get_children().live().type(ArticleChapterPage)
        return chapters

    base_panels_top = [
        FieldPanel("excerpt"),
    ]

    base_panels_bottom = [
        FieldPanel("body"),
    ]


class ArticlePage(ArticlePageBase):
    subpage_types = ["pages.ArticleChapterPage"]
    date = models.DateField("Article published date")

    panels_top = [
        MultiFieldPanel(
            ArticlePageBase.base_panels_top
            + [
                FieldPanel("date"),
            ],
            heading="Article information",
        )
    ]

    panels_bottom = [
        FieldPanel("body"),
    ]

    content_panels = Page.content_panels + panels_top + panels_bottom

    def get_context(self, request):
        context = super().get_context(request)
        context["chapters"] = self.get_children().live().type(ArticleChapterPage)
        return context


class ArticleChapterPage(ArticlePageBase):
    subpage_types = []

    panels_bottom = ArticlePageBase.base_panels_bottom

    content_panels = Page.content_panels + panels_bottom

    def get_context(self, request):
        context = super().get_context(request)
        context["article"] = self.get_parent()
        context["chapters"] = ArticleChapterPage.objects.live().sibling_of(
            self, inclusive=True
        )
        context["current_chapter"] = self
        return context


# PACKAGE MODELS
class PackageIndexPage(BasePage):
    subpage_types = ["pages.PackagePage"]
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
        context["packages"] = (
            PackagePage.objects.live().descendant_of(self).order_by("-date")
        )
        return context


class PackagePage(BasePage):
    parent_page_types = ["pages.PackageIndexPage"]
    body = StreamField(
        BaseBlocks,
        blank=True,
        use_json_field=True,
    )
    date = models.DateField("Package published date")
    excerpt = models.CharField(max_length=255, blank=True)

    content_panels = Page.content_panels + [
        FieldPanel("body"),
        FieldPanel("date"),
        FieldPanel("excerpt"),
    ]

    def get_latest_packages(self):
        packages = PackagePage.objects.live().order_by("-date")
        return packages[:3]

    def get_context(self, request):
        context = super().get_context(request)
        context["latest_packages"] = self.get_latest_packages()
        return context
