from wagtail import blocks


class BaseHeadingBlock(blocks.StructBlock):
    heading = blocks.CharBlock()
    level = blocks.ChoiceBlock(
        choices=[
            ("h1", "H1"),
            ("h2", "H2"),
            ("h3", "H3"),
            ("h4", "H4"),
            ("h5", "H5"),
            ("h6", "H6"),
        ]
    )

    class Meta:
        icon = "title"


class HeadingBlock(BaseHeadingBlock):
    class Meta:
        template = "blocks/heading.html"


class BaseBlocks(blocks.StreamBlock):
    rich_text = blocks.RichTextBlock()
    heading = HeadingBlock()
