# Generated by Django 4.1.10 on 2023-08-27 12:17

from django.db import migrations


class Migration(migrations.Migration):
    dependencies = [
        ("pages", "0004_articlechapterpage"),
    ]

    operations = [
        migrations.RemoveField(
            model_name="articlechapterpage",
            name="date",
        ),
    ]
