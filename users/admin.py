from django import forms
from django.contrib import admin
from django.contrib.auth.models import Group
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from django.contrib.auth.forms import ReadOnlyPasswordHashField
from django.core.exceptions import ValidationError

from users.models import User


class UserCreationForm(forms.ModelForm):
    """새 사용자를 생성하기 위한 폼. 필요한 모든 필드와 비밀번호 확인 필드를 포함합니다."""
    password1 = forms.CharField(label='비밀번호', widget=forms.PasswordInput)
    password2 = forms.CharField(label='비밀번호 확인', widget=forms.PasswordInput)

    class Meta:
        model = User
        fields = ('email', 'username', 'is_expert')

    def clean_password2(self):
        # 두 개의 비밀번호가 일치하는지 확인
        password1 = self.cleaned_data.get("password1")
        password2 = self.cleaned_data.get("password2")
        if password1 and password2 and password1 != password2:
            raise ValidationError("비밀번호가 일치하지 않습니다.")
        return password2

    def save(self, commit=True):
        # 제공된 비밀번호를 해시된 형태로 저장
        user = super().save(commit=False)
        user.set_password(self.cleaned_data["password1"])
        if commit:
            user.save()
        return user


class UserChangeForm(forms.ModelForm):
    """사용자 정보를 업데이트하기 위한 폼. 비밀번호 필드는 읽기 전용으로 표시됩니다."""
    password = ReadOnlyPasswordHashField()

    class Meta:
        model = User
        fields = ('password', 'email', 'username', 'is_expert', 'is_active', 'is_admin')


class UserAdmin(BaseUserAdmin):
    form = UserChangeForm
    add_form = UserCreationForm

    list_display = ('email', 'username', 'is_expert', 'is_admin')
    list_filter = ('is_admin',)

    fieldsets = (
        (None, {'fields': ('id', 'password')}),
        ('개인 정보', {'fields': ('username', 'email', 'is_expert')}),
        ('권한', {'fields': ('is_admin',)}),
    )

    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': ('email', 'username', 'password1', 'password2'),
        }),
    )

    add_user_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': ('email', 'username', 'is_expert', 'password1', 'password2'),
        }),
    )

    search_fields = ('id', 'email', 'username')
    ordering = ('id',)
    filter_horizontal = ()

    def get_fieldsets(self, request, obj=None):
        if not obj:  # 객체가 없을 때, 즉 사용자를 추가할 때
            if request.user.is_superuser:
                return self.add_fieldsets
            return self.add_user_fieldsets
        return super().get_fieldsets(request, obj)




# Register your models here.
admin.site.register(User, UserAdmin)