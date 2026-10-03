class NameParts {
  const NameParts({
    required this.firstName,
    required this.lastName,
  });

  final String firstName;
  final String lastName;
}

NameParts splitDisplayName(String? displayName) {
  final normalizedName = displayName?.trim() ?? '';

  if (normalizedName.isEmpty) {
    return const NameParts(
      firstName: '',
      lastName: '',
    );
  }

  final words = normalizedName.split(RegExp(r'\s+'));

  return NameParts(
    firstName: words.first,
    lastName: words.skip(1).join(' '),
  );
}