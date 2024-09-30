from django.contrib.auth.models import AbstractBaseUser, BaseUserManager, PermissionsMixin
from django.db import models

from users.models import User


class Article(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, default=4)

    article_id = models.AutoField(primary_key=True, unique=True)
    content = models.TextField(null=True, blank=True)
    image = models.ImageField(blank=True, null=True, upload_to='')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    likes = models.ManyToManyField(User, related_name='like_articles')
    #is_liked = models.BooleanField(default=False)

    def __str__(self):
        return str(self.content)

    def is_liked_by(self, user):
        return self.likes.filter(id=user.id).exists()


class Comment(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, default=4)
    article = models.ForeignKey(Article, on_delete=models.CASCADE, default=8, related_name='comments')
    content = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return str(self.content)
