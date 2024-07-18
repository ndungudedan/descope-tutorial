# Add Authentication to Your Web and Mobile Apps with Flutter

## Project Description

This project is the complete Flutter app for the tutorial **Add Authentication to Your Web and Mobile Apps with Flutter**. The project integrates Descope authentication into a Flutter app targeting both the Web and Mobile platforms. The project also demonstrates how to implement a role based access control feature into your app with Descope.

### Key Features:

- Configuring Descope Authentication Flows: Build comprehensive authentication flows with Descope Flows.

- Cross-Platform Support: Use the Descope Flutter SDK to seamlessly integrate Descope authentication into both web and mobile versions of your Flutter app.

- Secure Authentication: Utilize Descope’s robust authentication mechanisms to ensure secure user login and registration processes.

- Role-Based Access Control: Implement RBAC to manage user permissions and access levels effectively within your application.

## Getting Started
### Prerequisites

- A [Descope account](https://www.descope.com/sign-up) (free tier available)
- A basic understanding of Flutter development and [Dart](https://dart.dev/) programming
- A Flutter development environment set up (IDE or command line tools)

### Running the Project Locally

1. Clone the GitHub repository and open the project using Vscode:

    ```
    git clone https://github.com/ndungudedan/descope-tutorial
    ```

2. Install the packages:

    ```
    flutter pub get
    ```
3. Configure Descope:

    Follow Descope’s documentation to obtain your API keys and configure them in your Flutter app.

4. Run the app:

- Connect a physical mobile device or start an emulator.

- Use Vscode to build and run the app on Android, iOS or on the Web.

- Or run the mobile app from the command line by executing the command below:

    ```
    flutter run
    ```
- For the web:

    ```
    flutter run -d web-server --web-port 8080 --web-hostname 0.0.0.0
    ```