# Generated by Django 4.1.10 on 2023-08-29 15:51

import wagtail.blocks
import wagtail.fields
import wagtail.images.blocks
from django.db import migrations


class Migration(migrations.Migration):
    dependencies = [
        ("home", "0003_homepage_body"),
    ]

    operations = [
        migrations.AlterField(
            model_name="homepage",
            name="body",
            field=wagtail.fields.StreamField(
                [
                    (
                        "heading",
                        wagtail.blocks.StructBlock(
                            [
                                ("heading", wagtail.blocks.CharBlock()),
                                (
                                    "level",
                                    wagtail.blocks.ChoiceBlock(
                                        choices=[
                                            ("h1", "H1"),
                                            ("h2", "H2"),
                                            ("h3", "H3"),
                                            ("h4", "H4"),
                                            ("h5", "H5"),
                                            ("h6", "H6"),
                                        ]
                                    ),
                                ),
                            ]
                        ),
                    ),
                    (
                        "callout",
                        wagtail.blocks.RichTextBlock(template="blocks/callout.html"),
                    ),
                    ("rich_text", wagtail.blocks.RichTextBlock()),
                    (
                        "code",
                        wagtail.blocks.StructBlock(
                            [
                                ("code", wagtail.blocks.TextBlock()),
                                (
                                    "language",
                                    wagtail.blocks.ChoiceBlock(
                                        choices=[
                                            ("bash", "Bash"),
                                            ("css", "CSS"),
                                            ("html", "HTML"),
                                            ("javascript", "JavaScript"),
                                            ("json", "JSON"),
                                            ("python", "Python"),
                                            ("yaml", "YAML"),
                                        ]
                                    ),
                                ),
                            ]
                        ),
                    ),
                    (
                        "image_aligned_block",
                        wagtail.blocks.StructBlock(
                            [
                                ("image", wagtail.images.blocks.ImageChooserBlock()),
                                (
                                    "alignment",
                                    wagtail.blocks.ChoiceBlock(
                                        choices=[
                                            ("left", "Left"),
                                            ("center", "Center"),
                                            ("right", "Right"),
                                        ]
                                    ),
                                ),
                                (
                                    "content",
                                    wagtail.blocks.RichTextBlock(required=False),
                                ),
                            ]
                        ),
                    ),
                ],
                blank=True,
                use_json_field=True,
            ),
        ),
    ]