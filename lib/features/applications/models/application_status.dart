enum ApplicationStatus {
  applied,
  reviewing,
  shortlisted,
  rejected,
  hired,
}

extension ApplicationStatusX on ApplicationStatus {
  String get label {
    switch (this) {
      case ApplicationStatus.applied:
        return 'Applied';
      case ApplicationStatus.reviewing:
        return 'Reviewing';
      case ApplicationStatus.shortlisted:
        return 'Shortlisted';
      case ApplicationStatus.rejected:
        return 'Rejected';
      case ApplicationStatus.hired:
        return 'Hired';
    }
  }

  String get value {
    return name[0].toUpperCase() + name.substring(1);
  }
}
