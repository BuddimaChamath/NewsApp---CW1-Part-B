# News App
This is a Flutter-based news application that fetches the latest news using the NewsAPI.

**Setup Instructions**

# 1. Clone the repository:

git clone <repository-url>

# 2. Navigate to the project directory:

            cd news_app

# 3. Open the project in your preferred IDE.

# 4. Add constants.dart:

   * Navigate to the directory: lib/utils/

   * Create a file named constants.dart.

   * Add the following code to the file and replace your_api_key with your actual NewsAPI key:


            class Constants {
            static const String baseUrl = 'https://newsapi.org/v2';
            static const String apiKey = 'your_api_key'; // Add your NewsAPI key here
            }

# 5. Run the project:

            flutter pub get
            flutter run