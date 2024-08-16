from django.db import models

# Create your models here.
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager, PermissionsMixin
from django.db import models

class UserManager(BaseUserManager):
    def create_user(self, email, username, is_expert=False, password=None):
        '''if not id:
            raise ValueError('유저 ID는 필수입니다.')'''
        if not email:
            raise ValueError('이메일은 필수입니다.')
        if not username:
            raise ValueError('닉네임은 필수입니다.')
        if not password:
            raise ValueError('비밀번호는 필수입니다.')

        user = self.model(
            id=id,
            email=self.normalize_email(email),
            username=username,
            is_expert=is_expert,
        )
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self,  email, username, password=None):
        user = self.create_user(

            email=email,
            username=username,
            password=password,
        )
        user.is_admin = True
        user.save(using=self._db)
        return user


class User(AbstractBaseUser):
    #기본키 자동 생성
    id = models.AutoField(primary_key=True, unique=True)
    email = models.EmailField(default='', max_length=50, unique=True)
    username = models.CharField(default='', max_length=30, unique=True)
    is_expert = models.BooleanField(default=False)
    profile_image = models.CharField(max_length=100, default='write.png')
    is_active = models.BooleanField(default=True)
    is_admin = models.BooleanField(default=False)
    following = models.ManyToManyField('self', symmetrical=False, related_name='followers', blank=True)

    objects = UserManager()

    USERNAME_FIELD = 'username'
    REQUIRED_FIELDS = ['email', ]

    def __str__(self):
        return self.username

    @property
    def is_staff(self):
        return self.is_admin

    def has_perm(self, perm, obj=None):
        return True

    def has_module_perms(self, app_label):
        return True
