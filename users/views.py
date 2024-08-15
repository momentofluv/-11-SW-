from django.shortcuts import render

from rest_framework import status, permissions
from rest_framework.generics import get_object_or_404
from rest_framework.serializers import Serializer
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from rest_framework_simplejwt.views import TokenObtainPairView

from users.models import User
from users.serializers import UserSerializer, CustomTokenObtainPairSerializer, UserProfileSerializer
from django.db.models.query_utils import Q





class UserView(APIView):

    def post(self, request):
        serializer = UserSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response({"message": "가입완료"}, status=status.HTTP_201_CREATED)
        else:
            return Response({"message": f"${serializer.errors}"}, status=status.HTTP_400_BAD_REQUEST)


class CustomTokenObtainPairView(TokenObtainPairView):
    serializer_class = CustomTokenObtainPairSerializer


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

