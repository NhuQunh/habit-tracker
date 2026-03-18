enum AppLanguage { vietnamese, english }

class LocalizationService {
  static const Map<String, Map<String, String>> _translations = {
    'en': {
      // Home Screen
      'today': 'Today',
      'streaks': 'Streaks',
      'completed': 'Completed',
      'tasks': 'Tasks',
      'filter': 'Filter',
      'all': 'All',
      'completed_today': 'Completed Today',
      'not_completed': 'Not Completed',
      'longest_streak': 'Longest Streak',
      'search_habits': 'Search habits...',
      'delete_confirm': 'Delete habit?',
      'delete_cancel': 'Cancel',
      'delete_confirm_btn': 'Delete',

      // Settings Screen
      'settings': 'Settings',
      'customize': 'Customize your habit tracking experience.',
      'dark_mode': 'Dark Mode',
      'dark_mode_desc': 'Enable/disable dark mode',
      'daily_reminder': 'Daily Reminder',
      'daily_reminder_desc': 'Send notification at 7:00 every morning',
      'weekly_report': 'Weekly Report',
      'weekly_report_desc': 'Summary of habit completion',
      'language': 'Language',
      'language_desc': 'Choose app language',
      'app_version': 'App Version',
      'version': '1.0.0',

      // Statistics Screen
      'statistics': 'Statistics',
      'weekly_overview': 'Weekly Overview',
      'completion_rate': 'Completion Rate',
      'total_habits': 'Total Habits',
      'active_streaks': 'Active Streaks',

      // Habit Detail Screen
      'habit_details': 'Habit Details',
      'edit_habit': 'Edit Habit',
      'completion_dates': 'Completion Dates',
      'current_streak': 'Current Streak',
      'longest_streak_value': 'Longest Streak',
      'start_date': 'Start Date',

      // Bottom Navigation
      'home': 'Home',
      'stats': 'Stats',
    },
    'vi': {
      // Home Screen
      'today': 'Hôm nay',
      'streaks': 'Chuỗi ngày',
      'completed': 'Hoàn thành',
      'tasks': 'Nhiệm vụ',
      'filter': 'Lọc',
      'all': 'Tất cả',
      'completed_today': 'Đã hoàn thành hôm nay',
      'not_completed': 'Chưa hoàn thành',
      'longest_streak': 'Streak dài nhất',
      'search_habits': 'Tìm kiếm thói quen...',
      'delete_confirm': 'Xoá thói quen?',
      'delete_cancel': 'Huỷ',
      'delete_confirm_btn': 'Xoá',

      // Settings Screen
      'settings': 'Cài đặt',
      'customize': 'Tùy chỉnh trải nghiệm theo dõi thói quen.',
      'dark_mode': 'Chế độ tối',
      'dark_mode_desc': 'Bật/tắt chế độ tối',
      'daily_reminder': 'Nhắc nhở hàng ngày',
      'daily_reminder_desc': 'Gửi thông báo vào 7:00 mỗi sáng',
      'weekly_report': 'Báo cáo cuối tuần',
      'weekly_report_desc': 'Tổng hợp mức độ hoàn thành habit',
      'language': 'Ngôn ngữ',
      'language_desc': 'Chọn ngôn ngữ ứng dụng',
      'app_version': 'Phiên bản ứng dụng',
      'version': '1.0.0',

      // Statistics Screen
      'statistics': 'Thống kê',
      'weekly_overview': 'Tổng quan hàng tuần',
      'completion_rate': 'Tỷ lệ hoàn thành',
      'total_habits': 'Tổng thói quen',
      'active_streaks': 'Chuỗi ngày hoạt động',

      // Habit Detail Screen
      'habit_details': 'Chi tiết thói quen',
      'edit_habit': 'Chỉnh sửa thói quen',
      'completion_dates': 'Ngày hoàn thành',
      'current_streak': 'Chuỗi ngày hiện tại',
      'longest_streak_value': 'Chuỗi ngày dài nhất',
      'start_date': 'Ngày bắt đầu',

      // Bottom Navigation
      'home': 'Trang chủ',
      'stats': 'Thống kê',
    },
  };

  static String translate(String key, AppLanguage language) {
    final langCode = language == AppLanguage.english ? 'en' : 'vi';
    return _translations[langCode]?[key] ?? key;
  }

  static String languageName(AppLanguage language) {
    return language == AppLanguage.english ? 'English' : 'Tiếng Việt';
  }
}
