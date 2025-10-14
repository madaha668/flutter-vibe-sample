from django.urls import path

from . import views

app_name = 'accounts'

urlpatterns = [
    path('signup/', views.SignUpView.as_view(), name='signup'),
    path('signin/', views.SignInView.as_view(), name='signin'),
    path('refresh/', views.SessionRefreshView.as_view(), name='refresh'),
    path('signout/', views.SignOutView.as_view(), name='signout'),
    path('me/', views.CurrentUserView.as_view(), name='me'),
]
