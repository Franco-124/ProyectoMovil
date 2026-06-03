class ProfileState {
  final bool isLoading;
  final String userName;
  final String userEmail;
  final String tripsCount;
  final String totalDistance;
  final String userLevel;
  final String co2Saved;
  final String userRating;
  final String? error;

  const ProfileState({
    this.isLoading = false,
    this.userName = 'Juan Pérez',
    this.userEmail = 'juan.perez@ebike.com',
    this.tripsCount = '42',
    this.totalDistance = '156.4',
    this.userLevel = 'Premium Member',
    this.co2Saved = '12kg',
    this.userRating = '4.9',
    this.error,
  });
}
