from django.urls import path,include
from . import views
from rest_framework_simplejwt.views import (
    TokenObtainPairView,
    TokenRefreshView,
)

urlpatterns = [
    path('signup/', views.UserView.as_view(), name='user_view'),
    path('login/', views.UserLoginView.as_view(), name='user_login'),
    path('logout/', views.UserLogoutView.as_view(), name='user_logout'),

    path('mock/', views.MockView.as_view(), name='mock_view'),
    #JWT 인증 사용
    path('api/token/', views.CustomTokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('follow/<int:id>/', views.FollowView.as_view(), name='follow_view'),
    path('<int:id>/', views.ProfileView.as_view(), name='profile_view')

]
