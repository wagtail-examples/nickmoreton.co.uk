from wagtail import blocks
from wagtail.contrib.settings.models import BaseSiteSetting, register_setting
from wagtail.fields import StreamField


@register_setting(icon="list-ul")
class Navigation(BaseSiteSetting):
    main_menu = StreamField(
        [
            (
                "main_menu",
                blocks.StructBlock(
                    [
                        ("label", blocks.CharBlock(required=True)),
                        ("page", blocks.PageChooserBlock()),
                    ]
                ),
            ),
        ],
        blank=True,
        use_json_field=True,
    )
