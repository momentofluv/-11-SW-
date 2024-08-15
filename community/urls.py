from rest_framework import routers
from django.urls import path,include
from . import views



urlpatterns = [
    path('', views.ArticleView.as_view(), name='article_list'),
    path('<int:article_id>/', views.ArticleDetailView.as_view(), name='article_detail'),

    path('<int:article_id>/comment/', views.CommentView.as_view(), name='comment_view'),
    path('<int:article_id>/comment/<int:comment_id>/', views.CommentDetailView.as_view(), name='comment_detail_view'),
    path('<int:article_id>/like/', views.LikeView.as_view(), name='like_view'),

    #팔로우하고 있는 사람들의 글들을 볼 수 있는 Feed
    #path('feed/', views.FeedView.as_view(), name='feed_view')
]