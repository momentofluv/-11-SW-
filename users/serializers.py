from django.contrib.auth import authenticate
from rest_framework import serializers
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer

from community.serializers import ArticleListSerializer
from users.models import User


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = '__all__'

    def create(self, validated_data):
        user = super().create(validated_data)
        password = user.password
        user.set_password(password)
        user.save()
        return user

    def update(self, instance, validated_data):
        user = super().update(instance, validated_data)
        password = validated_data.get('password')
        if password:
            user.set_password(password)
            user.save()
        return user





class CustomTokenObtainPairSerializer(TokenObtainPairSerializer):
    @classmethod
    def get_token(cls, user):
        token = super().get_token(user)
        token['email'] = user.email
        token['username'] = user.username
        token['password'] = user.password
        return token

class UserProfileSerializer(serializers.ModelSerializer):
    #팔로워
    followers = serializers.StringRelatedField(many=True)
    #사용자가 작성한 글들 확인
    article_set = ArticleListSerializer(many=True)
    #사용자가 좋아요한 글들 확인
    like_articles = ArticleListSerializer(many=True)
    class Meta:
        model = User
        fields = ('id', 'email', 'username', 'following', 'followers', 'article_set', 'like_articles')