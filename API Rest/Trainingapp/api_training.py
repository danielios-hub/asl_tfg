from rest_framework.views import APIView
from ASLMachineLearning import settings
from django.http import JsonResponse
import os

class ImagesListAPI(APIView):
    """ List of urls images by letters"""
    def get(self, request):
        labelsClass = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "K",
                       "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U",
                       "V", "W", "X", "Y"]
        json_data = {}
        train_folder = os.path.join(settings.DATASET_ROOT_DIR, 'train')
        for letter in labelsClass:
            list_images = []
            for i in range(1, 7):
                folder_data = os.path.join(train_folder, str(i), letter)
                images_list = os.listdir(folder_data)
                for imageName in images_list:
                    url = settings.DATASET_URL + "train" + "/" + str(i) + "/" + letter + "/" + imageName
                    list_images.append(url)
            json_data[letter] = list_images
        return JsonResponse(json_data)