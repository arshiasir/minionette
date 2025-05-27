# Minionette

Minionette is a powerful and modern Flutter application designed for seamless MinIO file management. Built with the GetX pattern, it provides an intuitive interface for managing your MinIO storage while maintaining high performance and reliability.

## 🌟 Key Features

### File Management
- **Upload Files**: Drag-and-drop or select files to upload to your MinIO server
- **Download Files**: Download files directly to your device
- **File Organization**: View and manage files in a structured interface
- **Bulk Operations**: Perform multiple file operations simultaneously

### MinIO Integration
- **Secure Connection**: Connect to MinIO servers with SSL/TLS support
- **Configurable Settings**: Customize endpoint, access keys, and bucket settings
- **Real-time Status**: Monitor upload/download progress and connection status
- **Error Handling**: Automatic detection and display of file errors

### User Interface
- **Modern Design**: Clean and intuitive material design interface
- **Dark Mode**: Full support for dark and light themes
- **Responsive Layout**: Adapts to different screen sizes and orientations
- **Progress Indicators**: Visual feedback for all operations

### Advanced Features
- **Download Links**: Generate and manage shareable download links
- **File Details**: View comprehensive file information and metadata
- **Error Tracking**: Monitor and manage files with errors
- **Offline Support**: Queue operations when offline

## 🛠 Technical Architecture

### Project Structure
```
lib/
├── app/
│   ├── modules/           # Feature modules
│   │   ├── home/         # Main file management interface
│   │   ├── settings/     # MinIO configuration and app settings
│   │   └── file_details/ # Detailed file information view
│   ├── routes/           # Application routing
│   ├── services/         # Core services
│   │   ├── minio/        # MinIO client integration
│   │   ├── storage/      # Local storage management
│   │   └── auth/         # Authentication handling
│   ├── controllers/      # Business logic
│   ├── models/          # Data models
│   └── theme/           # UI theming
└── main.dart            # Application entry point
```

### Core Technologies
- **Flutter**: Cross-platform UI framework
- **GetX**: State management, routing, and dependency injection
- **MinIO Client**: Official MinIO SDK integration
- **File Picker**: Native file system integration
- **Dio**: Advanced HTTP client for network operations

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- MinIO server access
- Git

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/minionette.git
   cd minionette
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Configure environment:
   Create a `.env` file in the root directory:
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

## 💻 Usage Guide

### Connecting to MinIO
1. Launch the application
2. Navigate to Settings
3. Enter your MinIO server details
4. Test the connection
5. Save the configuration

### Managing Files
1. **Upload Files**:
   - Tap the upload button
   - Select files from your device
   - Monitor upload progress
   - View upload status

2. **Download Files**:
   - Select files to download
   - Choose download location
   - Monitor download progress
   - Access downloaded files

3. **Generate Links**:
   - Select a file
   - Tap the link icon
   - Copy the generated link
   - Share with others

4. **File Details**:
   - Tap on any file
   - View metadata
   - Check file status
   - Access file operations

## 🔧 Configuration

### Environment Variables
- `MINIO_ENDPOINT`: Your MinIO server URL
- `MINIO_ACCESS_KEY`: MinIO access key
- `MINIO_SECRET_KEY`: MinIO secret key
- `MINIO_BUCKET`: Default bucket name
- `MINIO_USE_SSL`: SSL/TLS configuration

### App Settings
- Theme selection (Light/Dark)
- Default download location
- Upload/download preferences
- Error handling preferences

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Development Guidelines
- Follow Flutter best practices
- Write clean, documented code
- Add tests for new features
- Update documentation as needed

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- GetX for state management
- MinIO for the storage solution
- All contributors and users

## 📞 Support

For support, please:
- Open an issue in the GitHub repository
- Check the documentation
- Contact the maintainers

---

Made with ❤️ by the Minionette team
