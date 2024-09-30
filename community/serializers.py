
#from rest_framework_simplejwt import TokenObtainPairSerializer
from rest_framework import serializers
from .models import Article, Comment

class ArticleListSerializer(serializers.ModelSerializer):
    user = serializers.SerializerMethodField()
    likes_count = serializers.SerializerMethodField()
    comment_count = serializers.SerializerMethodField()

    def get_user(self, obj):
        from users.serializers import UserSerializer  # 로컬 임포트
        return UserSerializer(obj.user).data

    def get_comment_count(self, obj):
        return obj.comments.count()

    def get_likes_count(self, obj):
        return obj.likes.count()

    class Meta:
        model = Article
        fields = ('article_id', 'content', 'image', 'created_at', 'updated_at', 'user', 'likes_count', 'comment_count')
class ArticleCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Article
        fields = ('content', 'image')

class CommentSerializer(serializers.ModelSerializer):
    class Meta:
        model = Comment
        exclude = ('article',)

class CommentCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Comment
        fields = ('content',)


class ArticleSerializer(serializers.ModelSerializer):
    user = serializers.SerializerMethodField()
    likes = serializers.StringRelatedField(many=True)
    likes_count = serializers.SerializerMethodField()

    comment_count = serializers.SerializerMethodField()
    def get_comment_count(self, obj):
        return obj.comments.count()

    def get_likes_count(self, obj):
        return obj.likes.count()

    def get_user(self, obj):
        return obj.user.username

    comments = CommentSerializer(many=True)

    class Meta:
        model = Article
        fields = '__all__'