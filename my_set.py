DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': 'fithubdb',#db명
        'USER': 'root', #db user 이름
        'PASSWORD': '12345678', #db password
        'HOST': 'mysql', #나중에 aws로 연결
        'PORT': '3306', #mysql 포트번호
    }
}
SECRET_KEY = 'django-insecure-$wpb(v8q5z*3$$c5^h0p(!7q#w8rm%3yw$^(*mkpvyj-pxc1dl'