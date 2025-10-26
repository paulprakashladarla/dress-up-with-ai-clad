# 👗 Dress Up with AI - Clad 👕

**Your personal AI stylist in your pocket!**

Clad is an iOS app that uses the power of Artificial Intelligence to help you create the perfect outfit from your own wardrobe. Say goodbye to decision fatigue and hello to effortless style!

## ✨ Features

*   **Wardrobe Digitization:** Easily add your clothing items to the app.
*   **AI-Powered Suggestions:** Get smart outfit recommendations based on your clothes.
*   **Occasion-Based Styling:** Find the right look for any event, from casual outings to formal dinners.
*   **Personalized Style Profile:** The app learns your preferences and tailors suggestions to your taste.

## 🛠️ Technologies Used

*   **Swift & SwiftUI:** For a modern, native iOS experience.
*   **Imagga API:** For powerful image recognition to categorize your clothing.
*   **Core Data:** To store your wardrobe locally on your device.

## 🚀 Getting Started

To run this project locally, you'll need Xcode and an Apple Developer account.

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/paulprakashladarla/dress-up-with-ai-clad.git
    ```
2.  **Open the project in Xcode:**
    ```bash
    cd dress-up-with-ai-clad
    open clad.xcodeproj
    ```
3.  **Configure API Keys:**
    *   You'll need to get your own API keys for the Imagga API.
    *   Create a file named `ImaggaConfig.swift` in the `dress up with ai` directory.
    *   Add the following content to the file, replacing `"YOUR_API_KEY"` and `"YOUR_API_SECRET"` with your actual credentials:
        ```swift
        struct ImaggaConfig {
            static let apiKey = "YOUR_API_KEY"
            static let apiSecret = "YOUR_API_SECRET"
        }
        ```
4.  **Build and Run:**
    *   Select your target device in Xcode and click the "Run" button.

## 📸 Screenshots

*(Add some screenshots of your app here to showcase its beautiful UI!)*

| Wardrobe | Suggestions | Outfit |
| :------: | :---------: | :----: |
| *(Image)* |  *(Image)*   | *(Image)* |


## 🙏 Acknowledgements

*   Thanks to the developers of the Imagga API for their amazing service.
