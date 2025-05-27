# Minionette

Minionette is a powerful and modern Flutter application designed for seamless MinIO file management. Built with the GetX pattern, it provides an intuitive interface for managing your MinIO storage while maintaining high performance and reliability.

## 🌟 Key Features

### File Management
- **Upload Files**: Drag-and-drop or select files to upload to your MinIO server
- **Download Files**: Download files directly to your device
- **File Organization**: View and manage files in a structured interface
- **Bulk Operations**: Perform multiple file operations simultaneously
- **File Details**: View comprehensive file information and metadata
- **Error Tracking**: Monitor and manage files with errors

### Bucket Management
- **Create Buckets**: Create new storage buckets with custom names
- **Delete Buckets**: Remove unused buckets (with safety checks)
- **Switch Buckets**: Easily switch between different buckets
- **Public Access Control**: Enable/disable public access for buckets
- **Bucket Status**: View bucket status and public access settings
- **Bucket Policies**: Manage bucket policies for access control

### MinIO Integration
- **Multiple Servers**: Support for multiple MinIO server configurations
- **Secure Connection**: Connect to MinIO servers with SSL/TLS support
- **Configurable Settings**: Customize endpoint, access keys, and bucket settings
- **Real-time Status**: Monitor upload/download progress and connection status
- **Error Handling**: Automatic detection and display of file errors
- **Connection Testing**: Test server connections before saving

### User Interface
- **Modern Design**: Clean and intuitive material design interface
- **Dark Mode**: Full support for dark and light themes
- **Responsive Layout**: Adapts to different screen sizes and orientations
- **Progress Indicators**: Visual feedback for all operations
- **Error Notifications**: Clear error messages and status updates
- **Interactive Bucket Management**: Visual bucket management interface

### Advanced Features
- **Download Links**: Generate and manage shareable download links
- **Public URLs**: Create public URLs for files in public buckets
- **Presigned URLs**: Generate time-limited presigned URLs
- **Offline Support**: Queue operations when offline
- **Error Recovery**: Automatic error handling and recovery
- **Status Persistence**: Remember bucket and connection states

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
- **GetStorage**: Persistent storage for configurations

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

3. Run the application:
   ```bash
   flutter run
   ```

## 💻 Usage Guide

### MinIO Server Configuration
The application supports multiple MinIO server configurations. You can add and manage your MinIO servers through the Settings interface:

1. Launch the application
2. Navigate to Settings
3. Click "Add Account" to configure a new MinIO server
4. Enter the following details:
   - **Account Name**: A friendly name for your MinIO server
   - **Endpoint**: Your MinIO server URL (e.g., play.min.io)
   - **Access Key**: Your MinIO access key
   - **Secret Key**: Your MinIO secret key
   - **Use SSL**: Toggle SSL/TLS connection

The application will:
- Test the connection automatically
- Save the configuration securely
- Allow you to switch between different MinIO servers
- Remember your last used server
- Display connection status and any errors

### Bucket Management
1. Access bucket management through the folder icon in the app bar
2. Create new buckets with custom names
3. Switch between buckets using the bucket list
4. Manage bucket public access settings
5. Delete unused buckets (with safety confirmation)

### File Operations
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
   - Choose link type (presigned or public)
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
- Bucket management preferences

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
