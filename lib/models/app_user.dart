// Declaration of the AppUser class with its properties
class AppUser {
  // Immutable fields that define attributes of the user
  final String id; // Unique identifier for the user (typically from Firebase Auth)
  final String email; // User's email address
  final String username; // User's chosen username
  final String address; // User's address, optional and defaults to empty
  final String profileImageUrl; // URL to the user's profile image, defaults to empty
  final String aboutMe; // A brief description about the user, optional and defaults to empty

  // Constructor for the AppUser class with required and optional parameters
  AppUser({
    required this.id, // 'id', 'email', and 'username' are required
    required this.email,
    required this.username,
    this.address = '', // Optional parameters with default values
    this.profileImageUrl = '',
    this.aboutMe = '',
  });

  // Factory constructor that creates an AppUser from a map of key/value pairs
  factory AppUser.fromMap(Map<String, dynamic> data) {
    // Returns a new instance of AppUser by extracting values from a Map
    // Uses null-aware operators to provide default values if the map does not contain specific keys
    return AppUser(
      id: data['id'] ?? '', // If 'id' is not in the map, default to an empty string
      email: data['email'] ?? '', // Similarly for email, username, and other fields
      username: data['username'] ?? '',
      address: data['address'] ?? '',
      profileImageUrl: data['profileImageUrl'] ?? '',
      aboutMe: data['aboutMe'] ?? '',
    );
  }

  // Method to convert the AppUser instance back into a map
  Map<String, dynamic> toMap() {
    // Returns a map containing the user's data
    return {
      'id': id,
      'email': email,
      'username': username,
      'address': address,
      'profileImageUrl': profileImageUrl,
      'aboutMe': aboutMe,
    };
  }

  // Method to create a new instance of AppUser with altered fields
  AppUser copyWith({
    String? email, // Optional parameters allow selective updating of fields
    String? username,
    String? address,
    String? profileImageUrl,
    String? aboutMe,
  }) {
    // Returns a new AppUser instance using the original instance's data with overrides from the parameters
    return AppUser(
      id: id, // ID is immutable and carries over from the current instance
      email: email ?? this.email, // Use the new email if provided, otherwise use the existing one
      username: username ?? this.username,
      address: address ?? this.address,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      aboutMe: aboutMe ?? this.aboutMe,
    );
  }
}
