class DepartmentConstants {
  static const Map<String, List<String>> facultiesAndDepartments = {
    'Faculty of Science and Information Technology (FSIT)': [
      'Department of Computer Science & Engineering',
      'Department of Computing & Information System (CIS)',
      'Department of Software Engineering',
      'Department of Environmental Science and Disaster Management',
      'Department of Multimedia & Creative Technology (MCT)',
      'Department of Information Technology and Management',
      'Department of Physical Education & Sports Science (PESS)',
    ],
    'Faculty of Engineering (FE)': [
      'Department of Information and Communication Engineering',
      'Department of Textile Engineering',
      'Department of Electrical & Electronic Engineering',
      'Department of Architecture',
      'Department of Civil Engineering',
    ],
    'Faculty of Health and Life Sciences (FHLS)': [
      'Department of Pharmacy',
      'Department of Public Health',
      'Department of Nutrition & Food Engineering',
      'Department of Agricultural Science (AGS)',
      'Department of Genetic Engineering and Biotechnology',
    ],
    'Faculty of Business and Entrepreneurship (FBE)': [
      'Department of Business Administration',
      'Department of Management',
      'Department of Real Estate',
      'Department of Tourism & Hospitality Management',
      'Department of Innovation & Entrepreneurship',
      'Department of Finance and Banking',
      'Department of Accounting',
      'Department of Marketing',
    ],
    'Faculty of Humanities and Social Sciences (FHSS)': [
      'Department of English',
      'Department of Law',
      'Department of Journalism & Mass Communication',
      'Department of Development Studies',
      'Department of Information Science and Library Management',
    ],
  };

  static List<String> get allDepartments {
    List<String> departments = [];
    facultiesAndDepartments.forEach((faculty, depts) {
      departments.addAll(depts);
    });
    return departments;
  }

  static List<String> get faculties => facultiesAndDepartments.keys.toList();

  static String? getFacultyByDepartment(String department) {
    for (var entry in facultiesAndDepartments.entries) {
      if (entry.value.contains(department)) {
        return entry.key;
      }
    }
    return null;
  }

  static List<String> getDepartmentsByFaculty(String faculty) {
    return facultiesAndDepartments[faculty] ?? [];
  }
}
