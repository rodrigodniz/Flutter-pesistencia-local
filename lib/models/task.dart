class Task {
  final int? id;
  final String title;
  final String description;
  final String priority;
  final bool completed;

  // Câmera (local)
  final String? photoPath;

  // S3 (novo - URL do objeto salvo no LocalStack)
  final String? imageUrl;

  final DateTime createdAt;
  final DateTime updatedAt;

  // Sensores (shake)
  final DateTime? completedAt;
  final String? completedBy; // 'manual' | 'shake'

  // GPS
  final double? latitude;
  final double? longitude;
  final String? locationName;

  // Offline-first
  final bool isSynced;

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.priority,
    this.completed = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.photoPath,
    this.imageUrl, // <-- NOVO
    this.completedAt,
    this.completedBy,
    this.latitude,
    this.longitude,
    this.locationName,
    this.isSynced = false,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? createdAt ?? DateTime.now();

  bool get hasPhoto => photoPath != null && photoPath!.isNotEmpty;
  bool get hasImageUrl => imageUrl != null && imageUrl!.isNotEmpty;
  bool get hasLocation => latitude != null && longitude != null;
  bool get wasCompletedByShake => completedBy == 'shake';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority,
      'completed': completed ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'photoPath': photoPath,
      'imageUrl': imageUrl, // <-- NOVO
      'completedAt': completedAt?.toIso8601String(),
      'completedBy': completedBy,
      'latitude': latitude,
      'longitude': longitude,
      'locationName': locationName,
      'isSynced': isSynced ? 1 : 0,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    final createdAtStr = map['createdAt'] as String?;
    final updatedAtStr = map['updatedAt'] as String?;

    final created = createdAtStr != null
        ? DateTime.parse(createdAtStr)
        : DateTime.now();

    final updated = updatedAtStr != null
        ? DateTime.parse(updatedAtStr)
        : created;

    return Task(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      priority: map['priority'] as String? ?? 'medium',
      completed: (map['completed'] as int? ?? 0) == 1,
      createdAt: created,
      updatedAt: updated,
      photoPath: map['photoPath'] as String?,
      imageUrl: map['imageUrl'] as String?, // <-- NOVO
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'] as String)
          : null,
      completedBy: map['completedBy'] as String?,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      locationName: map['locationName'] as String?,
      isSynced: (map['isSynced'] as int? ?? 0) == 1,
    );
  }

  Task copyWith({
    int? id,
    String? title,
    String? description,
    String? priority,
    bool? completed,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? photoPath,
    String? imageUrl, // <-- NOVO
    DateTime? completedAt,
    String? completedBy,
    double? latitude,
    double? longitude,
    String? locationName,
    bool? isSynced,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      photoPath: photoPath ?? this.photoPath,
      imageUrl: imageUrl ?? this.imageUrl, // <-- NOVO
      completedAt: completedAt ?? this.completedAt,
      completedBy: completedBy ?? this.completedBy,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
