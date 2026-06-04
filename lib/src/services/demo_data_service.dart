/// Central demo data source for all mock data across the app.
///
/// Each feature's repository reads from this service during development.
/// When the backend is ready, swap each repository's data source from
/// [DemoDataService] to actual Dio API calls — no UI changes needed.
class DemoDataService {
  DemoDataService._();
  static final DemoDataService instance = DemoDataService._();

  // ══════════════════════════════════════════════════════════════════════
  // DEMO ACCOUNTS
  // ══════════════════════════════════════════════════════════════════════

  /// Returns the demo profile for a phone number, or null if not found.
  Map<String, dynamic>? getAccountByPhone(String phone) {
    return _accounts[phone];
  }

  /// Validates demo credentials.
  bool validatePassword(String phone, String password) {
    final account = _accounts[phone];
    if (account == null) return false;
    return password == account['password'];
  }

  static final Map<String, Map<String, dynamic>> _accounts = {
    '092201931': {
      'password': 'student123',
      'token': 'demo-student-token-001',
      'role': 'student',
      'profile': {
        'id': 'STU-001',
        'name': 'Aung Min Htet',
        'phone': '092201931',
        'email': 'aungminhtet@sgtschool.edu',
        'grade': 'Grade 10',
        'section': 'A',
        'roll_no': '12',
        'admission_no': 'ADM20240012',
        'date_of_birth': '14 March 2010',
        'gender': 'Male',
        'address': 'No. 45, Bogyoke Road, Taunggyi',
        'class_teacher': 'U Thein Aung',
        'academic_year': '2025 - 2026',
        'parent_name': 'Daw Khin May',
        'parent_phone': '092201932',
        'parent_relation': 'Mother',
        'emergency_contact': '09200000002',
        'emergency_name': 'U Kyaw Soe',
        'photo_url': null,
      },
    },
    '092201932': {
      'password': 'parent123',
      'token': 'demo-parent-token-001',
      'role': 'parent',
      'profile': {
        'id': 'PAR-001',
        'name': 'Daw Khin May',
        'phone': '092201932',
        'email': 'khinmay@gmail.com',
        'date_of_birth': '5 January 1980',
        'gender': 'Female',
        'address': 'No. 45, Bogyoke Road, Taunggyi',
        'photo_url': null,
      },
    },
    '092201933': {
      'password': 'teacher123',
      'token': 'demo-teacher-token-001',
      'role': 'teacher',
      'profile': {
        'id': 'TCH-001',
        'name': 'U Thein Aung',
        'phone': '092201933',
        'email': 'theinaung@sgtschool.edu',
        'date_of_birth': '12 June 1975',
        'gender': 'Male',
        'address': 'No. 88, University Avenue, Taunggyi',
        'subject': 'Mathematics',
        'department': 'Science & Mathematics',
        'photo_url': null,
      },
    },
  };

  // ══════════════════════════════════════════════════════════════════════
  // STUDENT DATA
  // ══════════════════════════════════════════════════════════════════════

  /// 30 days of attendance records for a student.
  List<Map<String, dynamic>> getStudentAttendance(String studentId) {
    final now = DateTime.now();
    final records = <Map<String, dynamic>>[];

    for (var i = 30; i >= 1; i--) {
      final date = now.subtract(Duration(days: i));
      if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) continue;

      // Vary attendance status
      String status;
      String? timeIn;
      String? timeOut;

      if (i % 11 == 0) {
        status = 'absent';
      } else if (i % 7 == 0) {
        status = 'late';
        timeIn = '08:45 AM';
        timeOut = '03:30 PM';
      } else {
        status = 'present';
        timeIn = '07:50 AM';
        timeOut = '03:30 PM';
      }

      records.add({
        'date': '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
        'status': status,
        'time_in': timeIn,
        'time_out': timeOut,
      });
    }
    return records;
  }

  /// Weekly timetable (Mon-Fri, 6 periods each).
  Map<String, List<Map<String, dynamic>>> getStudentTimetable(String studentId) {
    return {
      'Monday': [
        {'period': 1, 'time': '08:00 AM - 08:45 AM', 'subject': 'Mathematics', 'room': 'Room 101', 'teacher': 'U Thein Aung'},
        {'period': 2, 'time': '08:45 AM - 09:30 AM', 'subject': 'Science', 'room': 'Room 102', 'teacher': 'Daw Aye Aye'},
        {'period': 3, 'time': '09:45 AM - 10:30 AM', 'subject': 'English', 'room': 'Room 103', 'teacher': 'U Myo Win'},
        {'period': 4, 'time': '10:30 AM - 11:15 AM', 'subject': 'History', 'room': 'Room 104', 'teacher': 'Daw Su Su'},
        {'period': 5, 'time': '11:30 AM - 12:15 PM', 'subject': 'Myanmar', 'room': 'Room 105', 'teacher': 'U Aung Ko'},
        {'period': 6, 'time': '01:00 PM - 01:45 PM', 'subject': 'Physical Education', 'room': 'Ground', 'teacher': 'U Zaw Win'},
      ],
      'Tuesday': [
        {'period': 1, 'time': '08:00 AM - 08:45 AM', 'subject': 'Science', 'room': 'Room 102', 'teacher': 'Daw Aye Aye'},
        {'period': 2, 'time': '08:45 AM - 09:30 AM', 'subject': 'Mathematics', 'room': 'Room 101', 'teacher': 'U Thein Aung'},
        {'period': 3, 'time': '09:45 AM - 10:30 AM', 'subject': 'Geography', 'room': 'Room 106', 'teacher': 'Daw Lin Lin'},
        {'period': 4, 'time': '10:30 AM - 11:15 AM', 'subject': 'English', 'room': 'Room 103', 'teacher': 'U Myo Win'},
        {'period': 5, 'time': '11:30 AM - 12:15 PM', 'subject': 'Computer', 'room': 'Lab 1', 'teacher': 'U Min Khant'},
        {'period': 6, 'time': '01:00 PM - 01:45 PM', 'subject': 'Art', 'room': 'Room 107', 'teacher': 'Daw Phyu Phyu'},
      ],
      'Wednesday': [
        {'period': 1, 'time': '08:00 AM - 08:45 AM', 'subject': 'English', 'room': 'Room 103', 'teacher': 'U Myo Win'},
        {'period': 2, 'time': '08:45 AM - 09:30 AM', 'subject': 'History', 'room': 'Room 104', 'teacher': 'Daw Su Su'},
        {'period': 3, 'time': '09:45 AM - 10:30 AM', 'subject': 'Mathematics', 'room': 'Room 101', 'teacher': 'U Thein Aung'},
        {'period': 4, 'time': '10:30 AM - 11:15 AM', 'subject': 'Science', 'room': 'Room 102', 'teacher': 'Daw Aye Aye'},
        {'period': 5, 'time': '11:30 AM - 12:15 PM', 'subject': 'Myanmar', 'room': 'Room 105', 'teacher': 'U Aung Ko'},
        {'period': 6, 'time': '01:00 PM - 01:45 PM', 'subject': 'Geography', 'room': 'Room 106', 'teacher': 'Daw Lin Lin'},
      ],
      'Thursday': [
        {'period': 1, 'time': '08:00 AM - 08:45 AM', 'subject': 'Myanmar', 'room': 'Room 105', 'teacher': 'U Aung Ko'},
        {'period': 2, 'time': '08:45 AM - 09:30 AM', 'subject': 'Mathematics', 'room': 'Room 101', 'teacher': 'U Thein Aung'},
        {'period': 3, 'time': '09:45 AM - 10:30 AM', 'subject': 'Science', 'room': 'Room 102', 'teacher': 'Daw Aye Aye'},
        {'period': 4, 'time': '10:30 AM - 11:15 AM', 'subject': 'Computer', 'room': 'Lab 1', 'teacher': 'U Min Khant'},
        {'period': 5, 'time': '11:30 AM - 12:15 PM', 'subject': 'English', 'room': 'Room 103', 'teacher': 'U Myo Win'},
        {'period': 6, 'time': '01:00 PM - 01:45 PM', 'subject': 'History', 'room': 'Room 104', 'teacher': 'Daw Su Su'},
      ],
      'Friday': [
        {'period': 1, 'time': '08:00 AM - 08:45 AM', 'subject': 'Geography', 'room': 'Room 106', 'teacher': 'Daw Lin Lin'},
        {'period': 2, 'time': '08:45 AM - 09:30 AM', 'subject': 'English', 'room': 'Room 103', 'teacher': 'U Myo Win'},
        {'period': 3, 'time': '09:45 AM - 10:30 AM', 'subject': 'Myanmar', 'room': 'Room 105', 'teacher': 'U Aung Ko'},
        {'period': 4, 'time': '10:30 AM - 11:15 AM', 'subject': 'Mathematics', 'room': 'Room 101', 'teacher': 'U Thein Aung'},
        {'period': 5, 'time': '11:30 AM - 12:15 PM', 'subject': 'Art', 'room': 'Room 107', 'teacher': 'Daw Phyu Phyu'},
        {'period': 6, 'time': '01:00 PM - 01:45 PM', 'subject': 'Physical Education', 'room': 'Ground', 'teacher': 'U Zaw Win'},
      ],
    };
  }

  /// Subjects with teachers.
  List<Map<String, dynamic>> getSubjects(String studentId) {
    return [
      {'id': 'SUB-01', 'name': 'Mathematics', 'teacher': 'U Thein Aung', 'icon': 'calculate'},
      {'id': 'SUB-02', 'name': 'Science', 'teacher': 'Daw Aye Aye', 'icon': 'science'},
      {'id': 'SUB-03', 'name': 'English', 'teacher': 'U Myo Win', 'icon': 'menu_book'},
      {'id': 'SUB-04', 'name': 'History', 'teacher': 'Daw Su Su', 'icon': 'history_edu'},
      {'id': 'SUB-05', 'name': 'Geography', 'teacher': 'Daw Lin Lin', 'icon': 'public'},
      {'id': 'SUB-06', 'name': 'Computer', 'teacher': 'U Min Khant', 'icon': 'computer'},
      {'id': 'SUB-07', 'name': 'Myanmar', 'teacher': 'U Aung Ko', 'icon': 'translate'},
      {'id': 'SUB-08', 'name': 'Physical Education', 'teacher': 'U Zaw Win', 'icon': 'sports_soccer'},
    ];
  }

  /// Exams list (upcoming + completed).
  List<Map<String, dynamic>> getExams(String studentId) {
    return [
      {
        'id': 'EXM-01', 'name': 'Mid Term Exam', 'class': 'Grade 10 - A',
        'date': '10 Mar, 2026', 'status': 'completed',
        'percentage': 85.0, 'grade': 'A',
        'subjects': [
          {'name': 'Mathematics', 'marks': 88, 'total': 100},
          {'name': 'Science', 'marks': 82, 'total': 100},
          {'name': 'English', 'marks': 78, 'total': 100},
          {'name': 'History', 'marks': 90, 'total': 100},
          {'name': 'Geography', 'marks': 87, 'total': 100},
          {'name': 'Computer', 'marks': 85, 'total': 100},
        ],
      },
      {
        'id': 'EXM-02', 'name': 'Unit Test 1', 'class': 'Grade 10 - A',
        'date': '19 Jan, 2026', 'status': 'completed',
        'percentage': 78.0, 'grade': 'B+',
        'subjects': [
          {'name': 'Mathematics', 'marks': 75, 'total': 100},
          {'name': 'Science', 'marks': 80, 'total': 100},
          {'name': 'English', 'marks': 72, 'total': 100},
          {'name': 'History', 'marks': 85, 'total': 100},
          {'name': 'Geography', 'marks': 76, 'total': 100},
          {'name': 'Computer', 'marks': 80, 'total': 100},
        ],
      },
      {
        'id': 'EXM-03', 'name': 'Unit Test 2', 'class': 'Grade 10 - A',
        'date': '20 Feb, 2026', 'status': 'completed',
        'percentage': 82.0, 'grade': 'A-',
        'subjects': [
          {'name': 'Mathematics', 'marks': 82, 'total': 100},
          {'name': 'Science', 'marks': 85, 'total': 100},
          {'name': 'English', 'marks': 79, 'total': 100},
          {'name': 'History', 'marks': 88, 'total': 100},
          {'name': 'Geography', 'marks': 78, 'total': 100},
          {'name': 'Computer', 'marks': 80, 'total': 100},
        ],
      },
      {
        'id': 'EXM-04', 'name': 'Final Exam', 'class': 'Grade 10 - A',
        'date': '15 May, 2026', 'status': 'upcoming',
        'percentage': null, 'grade': null, 'subjects': [],
      },
      {
        'id': 'EXM-05', 'name': 'Unit Test 3', 'class': 'Grade 10 - A',
        'date': '16 Apr, 2026', 'status': 'upcoming',
        'percentage': null, 'grade': null, 'subjects': [],
      },
    ];
  }

  /// Fee records.
  List<Map<String, dynamic>> getFees(String studentId) {
    return [
      {
        'id': 1,
        'student_name': 'Ellena',
        'fee_type': 'Tuition Fee',
        'amount_paid': 600.00,
        'total_paid': 600.00,
        'due': 0.0,
        'total_due': 0.0,
        'payment_status': 'paid',
        'payment_date': '2026-06-03',
        'fees_paid_by': 'parents',
        'payment_mode': 'cash'
      },
      {
        'id': 2,
        'student_name': 'Ellena',
        'fee_type': 'Transport Fee',
        'amount_paid': 200.00,
        'total_paid': 200.00,
        'due': 0.0,
        'total_due': 0.0,
        'payment_status': 'paid',
        'payment_date': '2026-06-03',
        'fees_paid_by': 'parents',
        'payment_mode': 'cash'
      },
      {
        'id': 3,
        'student_name': 'Ellena',
        'fee_type': 'Library Fee',
        'amount_paid': 0.0,
        'total_paid': 0.0,
        'due': 100.00,
        'total_due': 100.00,
        'payment_status': 'due',
        'payment_date': null,
        'fees_paid_by': null,
        'payment_mode': null
      },
      {
        'id': 4,
        'student_name': 'Ellena',
        'fee_type': 'Exam Fee',
        'amount_paid': 0.0,
        'total_paid': 0.0,
        'due': 200.00,
        'total_due': 200.00,
        'payment_status': 'due',
        'payment_date': null,
        'fees_paid_by': null,
        'payment_mode': null
      },
      {
        'id': 5,
        'student_name': 'Ellena',
        'fee_type': 'Activity Fee',
        'amount_paid': 100.00,
        'total_paid': 100.00,
        'due': 0.0,
        'total_due': 0.0,
        'payment_status': 'paid',
        'payment_date': '2026-06-03',
        'fees_paid_by': 'parents',
        'payment_mode': 'cash'
      },
    ];
  }

  /// Payment history.
  List<Map<String, dynamic>> getPaymentHistory(String studentId) {
    return [
      {'date': '15 Jan, 2026', 'amount': 600.00, 'method': 'KBZ Pay', 'reference': 'PAY-2026-001'},
      {'date': '15 Jan, 2026', 'amount': 200.00, 'method': 'KBZ Pay', 'reference': 'PAY-2026-002'},
      {'date': '10 Feb, 2026', 'amount': 100.00, 'method': 'Cash', 'reference': 'PAY-2026-003'},
    ];
  }

  /// School activities / events.
  List<Map<String, dynamic>> getActivities() {
    return [
      {'id': 'ACT-01', 'title': 'Science Exhibition', 'date': '18 May, 2026', 'location': 'School Auditorium', 'status': 'upcoming'},
      {'id': 'ACT-02', 'title': 'Annual Sports Day', 'date': '25 May, 2026', 'location': 'School Ground', 'status': 'upcoming'},
      {'id': 'ACT-03', 'title': 'Art & Craft Competition', 'date': '05 Jun, 2026', 'location': 'Art Room', 'status': 'upcoming'},
      {'id': 'ACT-04', 'title': 'Debate Competition', 'date': '15 Mar, 2026', 'location': 'Seminar Hall', 'status': 'completed'},
      {'id': 'ACT-05', 'title': 'Myanmar New Year Celebration', 'date': '17 Apr, 2026', 'location': 'Main Hall', 'status': 'completed'},
    ];
  }

  // ══════════════════════════════════════════════════════════════════════
  // NOTIFICATIONS (shared across roles)
  // ══════════════════════════════════════════════════════════════════════

  List<Map<String, dynamic>> getNotifications(String role) {
    final shared = <Map<String, dynamic>>[
      {'id': 'NOT-01', 'title': 'Mid Term Exam Schedule', 'body': 'The mid term exam will start from 10 March, 2026.', 'time': '2h ago', 'category': 'exam'},
      {'id': 'NOT-02', 'title': 'Sports Day Event', 'body': "Annual sports day on 25 May. Please participate.", 'time': '1d ago', 'category': 'event'},
      {'id': 'NOT-03', 'title': 'Fee Reminder', 'body': 'Your exam fee is pending. Please pay soon.', 'time': '2d ago', 'category': 'fee'},
      {'id': 'NOT-04', 'title': 'Holiday Notice', 'body': 'School will remain closed on 30 May 2026.', 'time': '3d ago', 'category': 'notice'},
      {'id': 'NOT-05', 'title': 'New Assignment', 'body': 'A new assignment has been uploaded in Science.', 'time': '3d ago', 'category': 'assignment'},
      {'id': 'NOT-06', 'title': 'Parent Meeting', 'body': 'Parent-teacher meeting on 5 June 2026 at 10 AM.', 'time': '5d ago', 'category': 'notice'},
      {'id': 'NOT-07', 'title': 'Library Books Due', 'body': 'Please return library books by 1 June 2026.', 'time': '1w ago', 'category': 'notice'},
    ];
    return shared;
  }

  // ══════════════════════════════════════════════════════════════════════
  // PARENT DATA
  // ══════════════════════════════════════════════════════════════════════

  /// Children linked to a parent account.
  List<Map<String, dynamic>> getChildren(String parentId) {
    return [
      {
        'student_id': 'STU-001',
        'name': 'Aung Min Htet',
        'grade': 'Grade 10',
        'section': 'A',
        'roll_no': '12',
        'attendance_percentage': 92,
        'photo_url': null,
      },
      {
        'student_id': 'STU-002',
        'name': 'Aye Myat Mon',
        'grade': 'Grade 10',
        'section': 'A',
        'roll_no': '5',
        'attendance_percentage': 96,
        'photo_url': null,
      },
    ];
  }

  // ══════════════════════════════════════════════════════════════════════
  // TEACHER DATA
  // ══════════════════════════════════════════════════════════════════════

  /// Classes taught by a teacher.
  List<Map<String, dynamic>> getTeacherClasses(String teacherId) {
    return [
      {'id': 'CLS-01', 'name': 'Grade 10', 'section': 'A', 'subject': 'Mathematics', 'student_count': 35},
      {'id': 'CLS-02', 'name': 'Grade 10', 'section': 'B', 'subject': 'Mathematics', 'student_count': 32},
      {'id': 'CLS-03', 'name': 'Grade 9', 'section': 'A', 'subject': 'Mathematics', 'student_count': 38},
    ];
  }

  /// Students in a class (for teacher's class detail / attendance marking).
  List<Map<String, dynamic>> getClassStudents(String classId) {
    return [
      {'id': 'STU-001', 'name': 'Aung Min Htet', 'roll_no': '12', 'attendance_status': 'present'},
      {'id': 'STU-002', 'name': 'Aye Myat Mon', 'roll_no': '5', 'attendance_status': 'present'},
      {'id': 'STU-003', 'name': 'Hla Hla Win', 'roll_no': '8', 'attendance_status': 'present'},
      {'id': 'STU-004', 'name': 'Ko Ko Aung', 'roll_no': '15', 'attendance_status': 'absent'},
      {'id': 'STU-005', 'name': 'Lin Lin Oo', 'roll_no': '18', 'attendance_status': 'present'},
      {'id': 'STU-006', 'name': 'May Thin Zar', 'roll_no': '20', 'attendance_status': 'late'},
      {'id': 'STU-007', 'name': 'Min Min Aung', 'roll_no': '22', 'attendance_status': 'present'},
      {'id': 'STU-008', 'name': 'Nay Chi Aung', 'roll_no': '25', 'attendance_status': 'present'},
      {'id': 'STU-009', 'name': 'Phyo Wai Yan', 'roll_no': '28', 'attendance_status': 'present'},
      {'id': 'STU-010', 'name': 'Su Myat Noe', 'roll_no': '30', 'attendance_status': 'present'},
    ];
  }

  /// Assignments for a teacher.
  List<Map<String, dynamic>> getAssignments(String teacherId) {
    return [
      {
        'id': 'ASG-01', 'title': 'Algebra Practice Set',
        'class_name': 'Grade 10 - A', 'subject': 'Mathematics',
        'due_date': '20 May, 2026', 'status': 'active',
        'description': 'Complete exercises 1-20 from Chapter 5. Show all working.',
        'submitted_count': 28, 'total_count': 35,
      },
      {
        'id': 'ASG-02', 'title': 'Geometry Worksheet',
        'class_name': 'Grade 10 - B', 'subject': 'Mathematics',
        'due_date': '22 May, 2026', 'status': 'active',
        'description': 'Solve all problems from the worksheet distributed in class.',
        'submitted_count': 15, 'total_count': 32,
      },
      {
        'id': 'ASG-03', 'title': 'Number Theory Quiz',
        'class_name': 'Grade 9 - A', 'subject': 'Mathematics',
        'due_date': '10 Apr, 2026', 'status': 'completed',
        'description': 'Chapter 3 review quiz - 30 minutes.',
        'submitted_count': 38, 'total_count': 38,
      },
      {
        'id': 'ASG-04', 'title': 'Statistics Project',
        'class_name': 'Grade 10 - A', 'subject': 'Mathematics',
        'due_date': '1 Jun, 2026', 'status': 'active',
        'description': 'Collect real-world data and create charts. Present findings.',
        'submitted_count': 5, 'total_count': 35,
      },
    ];
  }

  // ══════════════════════════════════════════════════════════════════════
  // CALENDAR EVENTS (shared)
  // ══════════════════════════════════════════════════════════════════════

  List<Map<String, dynamic>> getCalendarEvents() {
    return [
      {'date': '2026-03-10', 'title': 'Mid Term Exam Starts', 'type': 'exam'},
      {'date': '2026-03-20', 'title': 'Mid Term Exam Ends', 'type': 'exam'},
      {'date': '2026-04-17', 'title': 'Myanmar New Year Holiday', 'type': 'holiday'},
      {'date': '2026-04-18', 'title': 'Myanmar New Year Holiday', 'type': 'holiday'},
      {'date': '2026-05-01', 'title': 'Labour Day Holiday', 'type': 'holiday'},
      {'date': '2026-05-15', 'title': 'Final Exam Starts', 'type': 'exam'},
      {'date': '2026-05-18', 'title': 'Science Exhibition', 'type': 'event'},
      {'date': '2026-05-25', 'title': 'Annual Sports Day', 'type': 'event'},
      {'date': '2026-05-30', 'title': 'School Holiday', 'type': 'holiday'},
      {'date': '2026-06-05', 'title': 'Art & Craft Competition', 'type': 'event'},
    ];
  }
  // ══════════════════════════════════════════════════════════════════════
  // RESULTS
  // ══════════════════════════════════════════════════════════════════════

  /// Returns exam results for a student.
  List<Map<String, dynamic>> getStudentResults(String studentId) {
    return [
      {'subject': 'Mathematics', 'marks': 92, 'total': 100, 'grade': 'A+'},
      {'subject': 'English', 'marks': 85, 'total': 100, 'grade': 'A'},
      {'subject': 'Science', 'marks': 78, 'total': 100, 'grade': 'B+'},
      {'subject': 'Myanmar', 'marks': 88, 'total': 100, 'grade': 'A'},
      {'subject': 'History', 'marks': 72, 'total': 100, 'grade': 'B'},
      {'subject': 'Geography', 'marks': 65, 'total': 100, 'grade': 'C+'},
    ];
  }
}
