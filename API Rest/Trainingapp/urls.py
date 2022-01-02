from django.urls import path, re_path
from Trainingapp.api_training import ImagesListAPI

urlpatterns = [
    path('training-images', ImagesListAPI.as_view()),
]