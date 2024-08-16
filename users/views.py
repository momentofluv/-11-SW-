from django.shortcuts import render
from rest_framework_simplejwt.tokens import RefreshToken
from django.contrib.auth import authenticate, login
from django.conf import settings
from rest_framework import status, permissions
from rest_framework.generics import get_object_or_404
from rest_framework.serializers import Serializer
from rest_framework.views import APIView
from rest_framework.permissions import *
from rest_framework.response import Response
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from rest_framework_simplejwt.views import TokenObtainPairView

from users.models import User
from users.serializers import UserSerializer, CustomTokenObtainPairSerializer, UserProfileSerializer

import random

class UserView(APIView):
    def post(self, request):
        serializer = UserSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()  # 사용자 객체 저장
            # 랜덤한 프로필 이미지 선택
            profile_images = ['profile1.png', 'profile2.png', 'profile3.png', 'profile4.png']
            selected_image = random.choice(profile_images)
            user.profile_image = f"{settings.STATIC_URL}images/{selected_image}"
            user.save()  # 사용자 객체 업데이트

            # JWT 토큰 생성
            refresh = RefreshToken.for_user(user)
            return Response({
                'refresh': str(refresh),
                'access': str(refresh.access_token),
                'message': '가입완료'
            }, status=status.HTTP_201_CREATED)
        else:
            return Response({"message": f"${serializer.errors}"}, status=status.HTTP_400_BAD_REQUEST)

class CustomTokenObtainPairView(TokenObtainPairView):
    serializer_class = CustomTokenObtainPairSerializer

class UserLoginView(APIView):
    permission_classes = [AllowAny]  # Allow any user to access this view

    def post(self, request):
        email = request.data.get('email')
        password = request.data.get('password')

        # Authenticate the user
        user = authenticate(request, email=email, password=password)

        if user is not None:
            refresh = RefreshToken.for_user(user)
            return Response({
                'refresh': str(refresh),
                'access': str(refresh.access_token),
            }, status=status.HTTP_200_OK)
        else:
            return Response({'message': '이메일 또는 비밀번호가 올바르지 않습니다.'}, status=status.HTTP_401_UNAUTHORIZED)

class UserLogoutView(APIView):
    class LogoutView(APIView):
        permission_classes = [IsAuthenticated]

        def post(self, request):
            try:
                refresh_token = request.data.get('refresh')
                token = RefreshToken(refresh_token)
                token.blacklist()  # 토큰을 블랙리스트에 추가하여 무효화
                return Response({'message': '로그아웃 성공'}, status=status.HTTP_205_RESET_CONTENT)
            except Exception as e:
                return Response({'message': '로그아웃 실패', 'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)

class MockView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        return Response("get 요청")


class FollowView(APIView):
    def post(self, request, id):
        you = get_object_or_404(User, id=id)
        me = request.user
        if me in you.followers.all():
            you.followers.remove(me)
            return Response({"message": "언팔로우 성공"}, status=status.HTTP_200_OK)
        else:
            you.followers.add(me)
            return Response({"message": "팔로우 성공"}, status=status.HTTP_200_OK)


class ProfileView(APIView):
    def get(self, request, id):
        user = get_object_or_404(User, id=id)
        serializer = UserProfileSerializer(user)
        return Response(serializer.data)

