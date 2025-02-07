class CourseDetailModel {
  final CourseInfo course;
  final List<String> purchasedCourses;

  CourseDetailModel({
    required this.course,
    required this.purchasedCourses,
  });

  factory CourseDetailModel.fromJson(Map<String, dynamic> json) {
    return CourseDetailModel(
      course: CourseInfo.fromJson(json['data']['course']),
      purchasedCourses: List<String>.from(json['data']['purchasedCourses'] ?? []),
    );
  }
}

class CourseInfo {
  final String id;
  final String title;
  final String department;
  final String duration;
  final String description;
  final String startDate;
  final double price;
  final String status;
  final String thumbnail;
  final int enrolledStudents;
  final double averageRating;
  final int totalReviews;
  final int totalModules;
  final int totalDuration;
  final bool isListed;

  final TutorDetails tutor;
  final List<CourseModule> modules;

  CourseInfo({
    required this.id,
    required this.title,
    required this.department,
    required this.duration,
    required this.description,
    required this.startDate,
    required this.price,
    required this.status,
    required this.thumbnail,
    required this.enrolledStudents,
    required this.averageRating,
    required this.totalReviews,
    required this.totalModules,
    required this.totalDuration,
    required this.isListed,
    required this.tutor,
    required this.modules,
  });

  factory CourseInfo.fromJson(Map<String, dynamic> json) {
    return CourseInfo(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      department: json['department'] ?? '',
      duration: json['duration'] ?? '',
      description: json['description'] ?? '',
      startDate: json['startDate'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      enrolledStudents: json['enrolledStudents'] ?? 0,
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      totalReviews: json['totalReviews'] ?? 0,
      totalModules: json['totalModules'] ?? 0,
      totalDuration: json['totalDuration'] ?? 0,
      isListed: json['isListed'] ?? false,
      tutor: TutorDetails.fromJson(json['tutorId'] ?? {}),
      modules: (json['modules'] as List<dynamic>?)
              ?.map((moduleJson) => CourseModule.fromJson(moduleJson))
              .toList() ??
          [],
    );
  }
}

class TutorDetails {
  final String id;
  final String department;
  final String name;
  final String email;
  final String education;
  final String experience;
  final String gender;
  final String profilePic;

  TutorDetails({
    required this.id,
    required this.department,
    required this.name,
    required this.email,
    required this.education,
    required this.experience,
    required this.gender,
    required this.profilePic,
  });

  factory TutorDetails.fromJson(Map<String, dynamic> json) {
    return TutorDetails(
      id: json['_id'] ?? '',
      department: json['department'] ?? '',
      name: json['tutorname'] ?? '',
      email: json['tutorEmail'] ?? '',
      education: json['education'] ?? '',
      experience: json['experiance'] ?? '',
      gender: json['gender'] ?? '',
      profilePic: json['profilePic'] ?? '',
    );
  }
}

class CourseModule {
  final String id;
  final String title;
  final String description;
  final int duration;
  final String videoUrl;
  final String status;

  CourseModule({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.videoUrl,
    required this.status,
  });

  factory CourseModule.fromJson(Map<String, dynamic> json) {
    return CourseModule(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      duration: json['duration'] ?? 0,
      videoUrl: json['video'] ?? '',
      status: json['status'] ?? '',
    );
  }
}