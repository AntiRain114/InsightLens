# InsightLens

InsightLens is a mobile application that allows users to capture images, identify objects within the images using AI, and retrieve relevant information about the identified objects. The app leverages the OpenAI API for image recognition and provides a user-friendly interface for seamless interaction. The purpose of designing this software is that conventional image recognition software is still not accurate enough. Therefore, the author chose to add the location of the photo taken in the query statement to help the large model identify the photographed items with higher accuracy.

## See the landing page here
https://antirain114.github.io/LANDINGFORIN/

## Features

- Camera functionality to capture images
- Image preprocessing and caching for efficient storage and retrieval
- Integration with the OpenAI API for object recognition and information retrieval
- At the same time, upload user positioning to help AI associate and make identification more accurate!
- User authentication and account management using Firebase Authentication
- Email verification for secure user registration
- Password reset functionality via email
- Settings page for managing app preferences
- Privacy policy and terms of service pages
- Search history and saved results for quick access
- This is search page
- ![Image text](https://github.com/AntiRain114/PIC/blob/6086f74dddc63b84b784787b79b4e26212cc1ed8/test.png)
- This is account page
- ![Image text](https://github.com/AntiRain114/PIC/blob/6086f74dddc63b84b784787b79b4e26212cc1ed8/test2.png)
- This is result page
- ![Image text](https://github.com/AntiRain114/PIC/blob/6086f74dddc63b84b784787b79b4e26212cc1ed8/test3.png)
- This is the warning 
- ![Image text](https://github.com/AntiRain114/PIC/blob/ae098866899e6ec6921b03cc315eaba55def810a/test4.jpg)
## Getting Started

To get started with InsightLens, follow these steps:

1. Clone the repository:git clone https://github.com/your-username/InsightLens.git
2. Install the required dependencies:flutter pub get
3. Set up Firebase:
- Create a new Firebase project at [https://console.firebase.google.com/](https://console.firebase.google.com/)
- Enable Firebase Authentication and configure the sign-in methods (email/password)
- Add your Android and iOS app to the Firebase project
- Download the `google-services.json` file for Android and `GoogleService-Info.plist` file for iOS and place them in the respective directories (`android/app` and `ios/Runner`)

4. Configure OpenAI API:
- Sign up for an OpenAI API key at [https://beta.openai.com/signup/](https://beta.openai.com/signup/)
- Create a `.env` file in the root directory of the project
- Add the following line to the `.env` file, replacing `YOUR_API_KEY` with your actual OpenAI API key:
  ```
  OPENAI_API_KEY=YOUR_API_KEY
  ```

5. You need to add your own firebase settings files, namely google-services.json (path is /android/app) and firebase_options.dart (path is /lib)

6. Run the app:flutter run


## Deployment

To deploy InsightLens, follow these steps:

1. Build the release version of the app:
- For Android:
  ```
  flutter build apk --release
  ```
- For iOS:
  ```
  flutter build ios --release
  ```

2. Sign the release build:
- For Android, sign the APK using your keystore
- For iOS, configure code signing in Xcode

3. Upload the signed build to the respective app stores (Google Play Store for Android, App Store for iOS)

4. Configure Firebase Hosting:
- Enable Firebase Hosting in your Firebase project
- Set up your custom domain (if desired)
- Deploy the web version of your app to Firebase Hosting

## Contributing

Contributions to InsightLens are welcome! If you find any bugs or have suggestions for improvements, please open an issue or submit a pull request.

## License

InsightLens is released under the [MIT License](LICENSE).

## Contact

If you have any questions or inquiries, please contact us at zhongjiezhe1973@hotmail.com.
