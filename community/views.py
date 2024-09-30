from django.db.models import Q
from drf_yasg.utils import swagger_auto_schema
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status, permissions
from rest_framework.decorators import api_view

from rest_framework.generics import get_object_or_404

from community.models import Article, Comment
from community.serializers import ArticleSerializer, ArticleCreateSerializer, ArticleListSerializer, CommentSerializer, CommentCreateSerializer


class ArticleView(APIView):

    # 게시글 전체 불러오기
    def get(self, request, format=None):
        articles = Article.objects.all()
        serializer = ArticleListSerializer(articles, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

    @swagger_auto_schema(request_body=ArticleCreateSerializer)
    def post(self, request, format=None):
        serializer = ArticleCreateSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        else:
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class ArticleDetailView(APIView):
    # 상세 페이지 불러오기
    def get(self, request, article_id, format=None):
        article = get_object_or_404(Article, article_id=article_id)
        serializer = ArticleSerializer(article)
        return Response(serializer.data)

    #커뮤니티 글 수정
    # 게시글 수정하기
    '''def put(self, request, article_id):
        article = get_object_or_404(Article, article_id=article_id)
        serializer = ArticleCreateSerializer(article, data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_200_OK)
        else:
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)'''
    def put(self, request, article_id):
        article = get_object_or_404(Article, article_id=article_id)
        if request.user == article.user:
            serializer = ArticleCreateSerializer(article, data=request.data)
            if serializer.is_valid():
                serializer.save()
                return Response(serializer.data, status=status.HTTP_200_OK)
            else:
                return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        else:
            return Response("권한이 없습니다!", status=status.HTTP_403_FORBIDDEN)

    #커뮤니티 글 삭제
    def delete(self, request, article_id, format=None):
        article = get_object_or_404(Article, article_id=article_id)
        if request.user == article.user:
            article.delete()
            return Response(status=status.HTTP_204_NO_CONTENT)
        else:
            return Response("권한이 없습니다!", status=status.HTTP_403_FORBIDDEN)


class CommentView(APIView):
    #댓글 가져오기
    def get(self, request, article_id):
        article = Article.objects.get(article_id=article_id)
        comments = article.comment_set.all()
        serializer = CommentSerializer(comments, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

    #댓글 생성
    def post(self, request, article_id):
        serializer = CommentCreateSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save(user = request.user, article_id = article_id)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        else:
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
class CommentDetailView(APIView):

    #댓글 수정
    def put(self, request, article_id, comment_id):
        comment = get_object_or_404(Comment, id=comment_id)
        if request.user == comment.user:
            serializer = CommentCreateSerializer(comment, data=request.data)
            if serializer.is_valid():
                serializer.save()
                return Response(serializer.data, status=status.HTTP_200_OK)
            else:
                return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        else:
            return Response("권한이 없습니다!", status=status.HTTP_403_FORBIDDEN)

    #댓글 삭제
    def delete(self, request, article_id, comment_id):
        comment = get_object_or_404(Comment, id=comment_id)
        if request.user == comment.user:
            comment.delete()
            return Response(status=status.HTTP_204_NO_CONTENT)
        else:
            return Response("권한이 없습니다!", status=status.HTTP_403_FORBIDDEN)

class LikeView(APIView):
    def post(self, request, article_id):
        article = get_object_or_404(Article, article_id=article_id)
        if request.user in article.likes.all():
            article.likes.remove(request.user)
            return Response("좋아요 취소했습니다.", status=status.HTTP_200_OK)
        else:
            article.likes.add(request.user)
            return Response("좋아요 했습니다.", status=status.HTTP_200_OK)


