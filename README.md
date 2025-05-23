# Minionette

A Flutter application for managing files in MinIO using the GetX pattern.

## Features

- Connect to MinIO server with configurable settings
- Upload files to MinIO
- Download files from MinIO
- Generate and retrieve download links
- Detect and display files with errors
- Modern UI with dark mode support

## Setup

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Create a `.env` file in the root directory with your MinIO configuration:
   ```
   MINIO_ENDPOINT=your-minio-endpoint
   MINIO_ACCESS_KEY=your-access-key
   MINIO_SECRET_KEY=your-secret-key
   MINIO_BUCKET=your-bucket-name
   MINIO_USE_SSL=true
   ```

4. Run the application:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── app/
│   ├── modules/
│   │   ├── home/
│   │   ├── settings/
│   │   └── file_details/
│   ├── routes/
│   ├── services/
│   └── theme/
└── main.dart
```

## Dependencies

- get: ^4.6.6 - State management, routing, and dependency injection
- minio: ^3.6.0 - MinIO client
- file_picker: ^6.1.1 - File picking functionality
- path_provider: ^2.1.2 - File system access
- dio: ^5.4.0 - HTTP client
- flutter_dotenv: ^5.1.0 - Environment variables
- permission_handler: ^11.2.0 - Permission handling

## Usage

1. Launch the application
2. Go to Settings and configure your MinIO connection
3. Use the main screen to:
   - Upload files using the floating action button
   - Download files using the download button
   - Get download links using the link button
   - Delete files using the delete button
4. View file details by tapping on a file
5. Monitor error files in the UI

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
