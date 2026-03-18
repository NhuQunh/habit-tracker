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
        'home_title': 'My Habits',
        'filter_list': 'Filter list',
        'switch_to_light': 'Switch to light mode',
        'switch_to_dark': 'Switch to dark mode',
        'keep_daily_habit': 'Keep habits every day',
        'completed_label': 'Completed',
        'today_rate': 'Today rate',
        'search_hint': 'Search by name, category, streak...',
        'no_habit_matches': 'No habits match the current filter',
        'try_filter_or_add': 'Try changing filter or add a new habit',
        'add_habit': 'Add habit',
        'congrats': 'Congratulations!',
        'milestone_message': '{habitName} reached {streak} streak days!',
        'delete_habit_message':
          'Are you sure you want to delete "{habitName}"? This action cannot be undone.',
        'habit_deleted': 'Habit deleted',

        // Add Habit Dialog
        'add_habit_title': 'Add new habit',
        'habit_name': 'Habit name',
        'habit_name_hint': 'Enter habit name',
        'habit_name_required': 'Habit name is required',
        'start_date': 'Start date',
        'category': 'Category',
        'category_required': 'Please choose a category',
        'cancel': 'Cancel',
        'save': 'Save',
        'category_health': 'Health',
        'category_learning': 'Learning',
        'category_productivity': 'Productivity',
        'category_mindfulness': 'Mindfulness',

        // Login
        'login_cancelled': 'Login cancelled',
        'login_subtitle': 'Sign in with Google to sync your habits.',
        'processing': 'Processing...',
        'sign_in_google': 'Sign in with Google',

        // Settings
        'sign_out_google': 'Sign out Google account',

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
        'home_title': 'Thói quen của tôi',
        'filter_list': 'Lọc danh sách',
        'switch_to_light': 'Chuyển sang chế độ sáng',
        'switch_to_dark': 'Chuyển sang chế độ tối',
        'keep_daily_habit': 'Duy trì thói quen mỗi ngày',
        'completed_label': 'Đã hoàn thành',
        'today_rate': 'Tỷ lệ hôm nay',
        'search_hint': 'Tìm theo tên, danh mục, streak...',
        'no_habit_matches': 'Chưa có thói quen phù hợp bộ lọc',
        'try_filter_or_add': 'Thử đổi bộ lọc hoặc thêm thói quen mới',
        'add_habit': 'Thêm thói quen',
        'congrats': 'Chúc mừng!',
        'milestone_message': '{habitName} đã đạt mốc {streak} ngày streak!',
        'delete_habit_message':
          'Bạn có chắc muốn xóa "{habitName}" không? Hành động này không thể hoàn tác.',
        'habit_deleted': 'Đã xóa thói quen',

        // Add Habit Dialog
        'add_habit_title': 'Thêm thói quen mới',
        'habit_name': 'Tên thói quen',
        'habit_name_hint': 'Nhập tên thói quen',
        'habit_name_required': 'Tên thói quen không được để trống',
        'start_date': 'Ngày bắt đầu',
        'category': 'Danh mục',
        'category_required': 'Bạn cần chọn danh mục',
        'cancel': 'Hủy',
        'save': 'Lưu',
        'category_health': 'Sức khỏe',
        'category_learning': 'Học tập',
        'category_productivity': 'Năng suất',
        'category_mindfulness': 'Chánh niệm',

        // Login
        'login_cancelled': 'Đăng nhập bị hủy',
        'login_subtitle': 'Đăng nhập với Google để đồng bộ thói quen của bạn.',
        'processing': 'Đang xử lý...',
        'sign_in_google': 'Đăng nhập với Google',

        // Settings
        'sign_out_google': 'Đăng xuất tài khoản Google',

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
