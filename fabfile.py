import os
import subprocess
from itertools import count

from fabric import Connection
from invoke import run as local
from invoke import task

if os.path.exists(".env"):
    # get values from .env file
    # cp example.env .env to create your own .env file
    with open(".env", "r") as f:
        for line in f.readlines():
            if not line or line.startswith("#") or "=" not in line:
                continue
            var, value = line.strip().split("=", 1)
            os.environ.setdefault(var, value)

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

connection = Connection(f'{os.environ["SSH_USER"]}@{os.environ["SSH_URL"]}')


def download_remote_db_backup(c):
    local(f'mkdir -p {BASE_DIR}/{os.getenv("BACKUP_DESTINATION")}')
    subprocess.run(
        [
            "scp",
            f'{os.environ["SSH_USER"]}@{os.environ["SSH_URL"]}:{os.environ["BACKUP_SOURCE"]}',
            f'{BASE_DIR}/{os.environ["BACKUP_DESTINATION"]}/{os.environ["BACKUP_FILE_NAME"]}',
        ]
    )


def download_remote_media(c):
    subprocess.run(
        [
            "scp",
            "-r",
            f'{os.environ["SSH_USER"]}@{os.environ["SSH_URL"]}:{os.environ["MEDIA_SOURCE"]}',
            f'{BASE_DIR}/{os.environ["MEDIA_DESTINATION"]}',
        ]
    )


def destroy_local_db(c):
    subprocess.run(["docker-compose", "down", "-v"])


def create_local_db(c):
    subprocess.run(["docker-compose", "up", "-d"])


def import_db(c):
    local(
        f'mysql -u {os.getenv("MYSQL_USER")} -p{os.getenv("MYSQL_PASSWORD")} {os.getenv("MYSQL_DATABASE")} \
            < {BASE_DIR}/{os.getenv("BACKUP_DESTINATION")}/{os.getenv("BACKUP_FILE_NAME")}'
    )


@task
def ssh(c):
    """SSH into PythonAnywhere"""
    connection.shell()


@task
def pull_db(c):
    """Pull database from PythonAnywhere to development machine"""
    with connection as c:
        download_remote_db_backup(c)
        import_db(c)


def download_s3_backup(c, path):
    # create the destination directory
    local(f'mkdir -p {BASE_DIR}/{os.getenv("BACKUP_DESTINATION")}')
    # remove any existing files in the destination directory
    local(f"rm -f {BASE_DIR}/{os.getenv('BACKUP_DESTINATION')}/*")
    subprocess.run(
        [
            "s3cmd",
            "get",
            path,
            f'{BASE_DIR}/{os.environ["BACKUP_DESTINATION"]}/{os.environ["BACKUP_FILE_NAME"]}',
        ]
    )


@task
def pull_db_s3(c):
    """Pull database from S3 to development machine"""
    s3_list = list_db_s3()

    for i, backup in zip(count(1), s3_list):
        print(f"{i}. {backup}")
    path = input("Enter the index to the S3 backup: ")
    with connection as c:
        download_s3_backup(c, s3_list[int(path) - 1])


def list_db_s3():
    """List database backups in S3"""
    with subprocess.Popen(
        ["s3cmd", "ls", os.environ["S3_DB_BUCKET_NAME"]], stdout=subprocess.PIPE
    ) as proc:
        lines = proc.stdout.readlines()
        lines_list = []
    for line in lines:
        line = line.decode().strip()
        if line.startswith("DIR"):
            lines_list.append(
                f'{line.split("DIR")[1].strip()}dbbackups/{os.environ["BACKUP_FILE_NAME"]}'
            )
    return lines_list


@task
def pull_media_s3(c):
    """Pull media from S3 to development machine"""
    s3_list = list_media_s3()

    for i, backup in zip(count(1), s3_list):
        print(f"{i}. {backup}")
    path = input("Enter the index to the S3 media: ")

    subprocess.run(
        [
            "s3cmd",
            "get",
            "--recursive",
            s3_list[int(path) - 1],
            f'{BASE_DIR}/{os.environ["MEDIA_DESTINATION"]}',
        ]
    )


def list_media_s3():
    """List media backups in S3"""
    with subprocess.Popen(
        ["s3cmd", "ls", os.environ["S3_MEDIA_BUCKET_NAME"]], stdout=subprocess.PIPE
    ) as proc:
        lines = proc.stdout.readlines()
        lines_list = []
    for line in lines:
        line = line.decode().strip()
        if line.startswith("DIR"):
            lines_list.append(f'{line.split("DIR")[1].strip()}media')
    return lines_list


@task
def pull_media(c):
    """Pull media from PythonAnywhere to development machine"""
    local(f'mkdir -p {BASE_DIR}/{os.getenv("MEDIA_DESTINATION")}')
    download_remote_media(c)
