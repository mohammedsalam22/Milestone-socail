// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name =
        (locale.countryCode?.isEmpty ?? false)
            ? locale.languageCode
            : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Login`
  String get login {
    return Intl.message('Login', name: 'login', desc: '', args: []);
  }

  /// `Welcome Back!`
  String get welcomeBack {
    return Intl.message(
      'Welcome Back!',
      name: 'welcomeBack',
      desc: '',
      args: [],
    );
  }

  /// `Login to your account`
  String get loginToAccount {
    return Intl.message(
      'Login to your account',
      name: 'loginToAccount',
      desc: '',
      args: [],
    );
  }

  /// `User Name`
  String get userName {
    return Intl.message('User Name', name: 'userName', desc: '', args: []);
  }

  /// `Enter your name`
  String get enterYourName {
    return Intl.message(
      'Enter your name',
      name: 'enterYourName',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your name`
  String get pleaseEnterYourName {
    return Intl.message(
      'Please enter your name',
      name: 'pleaseEnterYourName',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get password {
    return Intl.message('Password', name: 'password', desc: '', args: []);
  }

  /// `Enter your password`
  String get enterYourPassword {
    return Intl.message(
      'Enter your password',
      name: 'enterYourPassword',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your password`
  String get pleaseEnterYourPassword {
    return Intl.message(
      'Please enter your password',
      name: 'pleaseEnterYourPassword',
      desc: '',
      args: [],
    );
  }

  /// `Password must be at least 6 characters`
  String get passwordMinLength {
    return Intl.message(
      'Password must be at least 6 characters',
      name: 'passwordMinLength',
      desc: '',
      args: [],
    );
  }

  /// `Profile`
  String get profile {
    return Intl.message('Profile', name: 'profile', desc: '', args: []);
  }

  /// `Edit Profile`
  String get editProfile {
    return Intl.message(
      'Edit Profile',
      name: 'editProfile',
      desc: '',
      args: [],
    );
  }

  /// `Logout`
  String get logout {
    return Intl.message('Logout', name: 'logout', desc: '', args: []);
  }

  /// `Email`
  String get email {
    return Intl.message('Email', name: 'email', desc: '', args: []);
  }

  /// `First Name`
  String get firstName {
    return Intl.message('First Name', name: 'firstName', desc: '', args: []);
  }

  /// `Last Name`
  String get lastName {
    return Intl.message('Last Name', name: 'lastName', desc: '', args: []);
  }

  /// `Role`
  String get role {
    return Intl.message('Role', name: 'role', desc: '', args: []);
  }

  /// `Admin`
  String get admin {
    return Intl.message('Admin', name: 'admin', desc: '', args: []);
  }

  /// `Parent`
  String get parent {
    return Intl.message('Parent', name: 'parent', desc: '', args: []);
  }

  /// `Welcome, {name}!`
  String welcome(Object name) {
    return Intl.message(
      'Welcome, $name!',
      name: 'welcome',
      desc: '',
      args: [name],
    );
  }

  /// `Post title (optional)`
  String get postTitle {
    return Intl.message(
      'Post title (optional)',
      name: 'postTitle',
      desc: '',
      args: [],
    );
  }

  /// `What's on your mind?`
  String get whatsOnYourMind {
    return Intl.message(
      'What\'s on your mind?',
      name: 'whatsOnYourMind',
      desc: '',
      args: [],
    );
  }

  /// `Posts`
  String get posts {
    return Intl.message('Posts', name: 'posts', desc: '', args: []);
  }

  /// `Chats`
  String get chats {
    return Intl.message('Chats', name: 'chats', desc: '', args: []);
  }

  /// `Attendance`
  String get attendance {
    return Intl.message('Attendance', name: 'attendance', desc: '', args: []);
  }

  /// `Settings`
  String get settings {
    return Intl.message('Settings', name: 'settings', desc: '', args: []);
  }

  /// `Dark Mode`
  String get darkMode {
    return Intl.message('Dark Mode', name: 'darkMode', desc: '', args: []);
  }

  /// `Language`
  String get language {
    return Intl.message('Language', name: 'language', desc: '', args: []);
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `Save`
  String get save {
    return Intl.message('Save', name: 'save', desc: '', args: []);
  }

  /// `Delete`
  String get delete {
    return Intl.message('Delete', name: 'delete', desc: '', args: []);
  }

  /// `Edit`
  String get edit {
    return Intl.message('Edit', name: 'edit', desc: '', args: []);
  }

  /// `Create Post`
  String get createPost {
    return Intl.message('Create Post', name: 'createPost', desc: '', args: []);
  }

  /// `No posts yet`
  String get noPostsYet {
    return Intl.message('No posts yet', name: 'noPostsYet', desc: '', args: []);
  }

  /// `No posts available`
  String get noPostsAvailable {
    return Intl.message(
      'No posts available',
      name: 'noPostsAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Create your first post!`
  String get createFirstPost {
    return Intl.message(
      'Create your first post!',
      name: 'createFirstPost',
      desc: '',
      args: [],
    );
  }

  /// `Check back later for updates`
  String get checkBackLater {
    return Intl.message(
      'Check back later for updates',
      name: 'checkBackLater',
      desc: '',
      args: [],
    );
  }

  /// `Posts refreshed!`
  String get postsRefreshed {
    return Intl.message(
      'Posts refreshed!',
      name: 'postsRefreshed',
      desc: '',
      args: [],
    );
  }

  /// `Post created successfully!`
  String get postCreatedSuccessfully {
    return Intl.message(
      'Post created successfully!',
      name: 'postCreatedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `No files attached`
  String get noFilesAttached {
    return Intl.message(
      'No files attached',
      name: 'noFilesAttached',
      desc: '',
      args: [],
    );
  }

  /// `This post doesn't have any files`
  String get thisPostNoFiles {
    return Intl.message(
      'This post doesn\'t have any files',
      name: 'thisPostNoFiles',
      desc: '',
      args: [],
    );
  }

  /// `Files`
  String get files {
    return Intl.message('Files', name: 'files', desc: '', args: []);
  }

  /// `Photo`
  String get photo {
    return Intl.message('Photo', name: 'photo', desc: '', args: []);
  }

  /// `File`
  String get file {
    return Intl.message('File', name: 'file', desc: '', args: []);
  }

  /// `Location`
  String get location {
    return Intl.message('Location', name: 'location', desc: '', args: []);
  }

  /// `Please enter some content`
  String get pleaseEnterContent {
    return Intl.message(
      'Please enter some content',
      name: 'pleaseEnterContent',
      desc: '',
      args: [],
    );
  }

  /// `Your post will be visible to {shareType}`
  String yourPostVisibleTo(Object shareType) {
    return Intl.message(
      'Your post will be visible to $shareType',
      name: 'yourPostVisibleTo',
      desc: '',
      args: [shareType],
    );
  }

  /// `Public`
  String get public {
    return Intl.message('Public', name: 'public', desc: '', args: []);
  }

  /// `Parents Only`
  String get parentsOnly {
    return Intl.message(
      'Parents Only',
      name: 'parentsOnly',
      desc: '',
      args: [],
    );
  }

  /// `Teachers Only`
  String get teachersOnly {
    return Intl.message(
      'Teachers Only',
      name: 'teachersOnly',
      desc: '',
      args: [],
    );
  }

  /// `Students Only`
  String get studentsOnly {
    return Intl.message(
      'Students Only',
      name: 'studentsOnly',
      desc: '',
      args: [],
    );
  }

  /// `Share feature coming soon!`
  String get shareFeatureComingSoon {
    return Intl.message(
      'Share feature coming soon!',
      name: 'shareFeatureComingSoon',
      desc: '',
      args: [],
    );
  }

  /// `No files attached to this post`
  String get noFilesAttachedToPost {
    return Intl.message(
      'No files attached to this post',
      name: 'noFilesAttachedToPost',
      desc: '',
      args: [],
    );
  }

  /// `Post saved to favorites!`
  String get postSavedToFavorites {
    return Intl.message(
      'Post saved to favorites!',
      name: 'postSavedToFavorites',
      desc: '',
      args: [],
    );
  }

  /// `Edit functionality coming soon!`
  String get editFunctionalityComingSoon {
    return Intl.message(
      'Edit functionality coming soon!',
      name: 'editFunctionalityComingSoon',
      desc: '',
      args: [],
    );
  }

  /// `Comments`
  String get comments {
    return Intl.message('Comments', name: 'comments', desc: '', args: []);
  }

  /// `Like`
  String get like {
    return Intl.message('Like', name: 'like', desc: '', args: []);
  }

  /// `Share`
  String get share {
    return Intl.message('Share', name: 'share', desc: '', args: []);
  }

  /// `No chats yet`
  String get noChatsYet {
    return Intl.message('No chats yet', name: 'noChatsYet', desc: '', args: []);
  }

  /// `No chats available`
  String get noChatsAvailable {
    return Intl.message(
      'No chats available',
      name: 'noChatsAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Start a conversation!`
  String get startConversation {
    return Intl.message(
      'Start a conversation!',
      name: 'startConversation',
      desc: '',
      args: [],
    );
  }

  /// `Search chats`
  String get searchChats {
    return Intl.message(
      'Search chats',
      name: 'searchChats',
      desc: '',
      args: [],
    );
  }

  /// `Search feature coming soon!`
  String get searchFeatureComingSoon {
    return Intl.message(
      'Search feature coming soon!',
      name: 'searchFeatureComingSoon',
      desc: '',
      args: [],
    );
  }

  /// `New Group`
  String get newGroup {
    return Intl.message('New Group', name: 'newGroup', desc: '', args: []);
  }

  /// `New Chat`
  String get newChat {
    return Intl.message('New Chat', name: 'newChat', desc: '', args: []);
  }

  /// `New chat feature coming soon!`
  String get newChatFeatureComingSoon {
    return Intl.message(
      'New chat feature coming soon!',
      name: 'newChatFeatureComingSoon',
      desc: '',
      args: [],
    );
  }

  /// `Group created successfully!`
  String get groupCreatedSuccessfully {
    return Intl.message(
      'Group created successfully!',
      name: 'groupCreatedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Delete Chat`
  String get deleteChat {
    return Intl.message('Delete Chat', name: 'deleteChat', desc: '', args: []);
  }

  /// `Are you sure you want to delete this chat?`
  String get areYouSureDeleteChat {
    return Intl.message(
      'Are you sure you want to delete this chat?',
      name: 'areYouSureDeleteChat',
      desc: '',
      args: [],
    );
  }

  /// `Chat deleted successfully!`
  String get chatDeletedSuccessfully {
    return Intl.message(
      'Chat deleted successfully!',
      name: 'chatDeletedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Type a message...`
  String get typeMessage {
    return Intl.message(
      'Type a message...',
      name: 'typeMessage',
      desc: '',
      args: [],
    );
  }

  /// `Take Attendance`
  String get takeAttendance {
    return Intl.message(
      'Take Attendance',
      name: 'takeAttendance',
      desc: '',
      args: [],
    );
  }

  /// `Student Name`
  String get studentName {
    return Intl.message(
      'Student Name',
      name: 'studentName',
      desc: '',
      args: [],
    );
  }

  /// `Grade`
  String get grade {
    return Intl.message('Grade', name: 'grade', desc: '', args: []);
  }

  /// `Status (Present/Absent/Late)`
  String get statusPresentAbsentLate {
    return Intl.message(
      'Status (Present/Absent/Late)',
      name: 'statusPresentAbsentLate',
      desc: '',
      args: [],
    );
  }

  /// `Record`
  String get record {
    return Intl.message('Record', name: 'record', desc: '', args: []);
  }

  /// `Attendance recorded successfully!`
  String get attendanceRecordedSuccessfully {
    return Intl.message(
      'Attendance recorded successfully!',
      name: 'attendanceRecordedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `No students found`
  String get noStudentsFound {
    return Intl.message(
      'No students found',
      name: 'noStudentsFound',
      desc: '',
      args: [],
    );
  }

  /// `Export Attendance`
  String get exportAttendance {
    return Intl.message(
      'Export Attendance',
      name: 'exportAttendance',
      desc: '',
      args: [],
    );
  }

  /// `Filter`
  String get filter {
    return Intl.message('Filter', name: 'filter', desc: '', args: []);
  }

  /// `Open file`
  String get openFile {
    return Intl.message('Open file', name: 'openFile', desc: '', args: []);
  }

  /// `Download file`
  String get downloadFile {
    return Intl.message(
      'Download file',
      name: 'downloadFile',
      desc: '',
      args: [],
    );
  }

  /// `File path not available`
  String get filePathNotAvailable {
    return Intl.message(
      'File path not available',
      name: 'filePathNotAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Error opening file: {error}`
  String errorOpeningFile(Object error) {
    return Intl.message(
      'Error opening file: $error',
      name: 'errorOpeningFile',
      desc: '',
      args: [error],
    );
  }

  /// `Downloading {fileName}...`
  String downloadingFile(Object fileName) {
    return Intl.message(
      'Downloading $fileName...',
      name: 'downloadingFile',
      desc: '',
      args: [fileName],
    );
  }

  /// `Logged out successfully!`
  String get loggedOutSuccessfully {
    return Intl.message(
      'Logged out successfully!',
      name: 'loggedOutSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to logout?`
  String get areYouSureLogout {
    return Intl.message(
      'Are you sure you want to logout?',
      name: 'areYouSureLogout',
      desc: '',
      args: [],
    );
  }

  /// `Profile updated successfully!`
  String get profileUpdatedSuccessfully {
    return Intl.message(
      'Profile updated successfully!',
      name: 'profileUpdatedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Settings coming soon!`
  String get settingsComingSoon {
    return Intl.message(
      'Settings coming soon!',
      name: 'settingsComingSoon',
      desc: '',
      args: [],
    );
  }

  /// `Manage Users`
  String get manageUsers {
    return Intl.message(
      'Manage Users',
      name: 'manageUsers',
      desc: '',
      args: [],
    );
  }

  /// `System Settings`
  String get systemSettings {
    return Intl.message(
      'System Settings',
      name: 'systemSettings',
      desc: '',
      args: [],
    );
  }

  /// `Reports & Analytics`
  String get reportsAnalytics {
    return Intl.message(
      'Reports & Analytics',
      name: 'reportsAnalytics',
      desc: '',
      args: [],
    );
  }

  /// `Backup & Restore`
  String get backupRestore {
    return Intl.message(
      'Backup & Restore',
      name: 'backupRestore',
      desc: '',
      args: [],
    );
  }

  /// `View Child Progress`
  String get viewChildProgress {
    return Intl.message(
      'View Child Progress',
      name: 'viewChildProgress',
      desc: '',
      args: [],
    );
  }

  /// `Contact Teachers`
  String get contactTeachers {
    return Intl.message(
      'Contact Teachers',
      name: 'contactTeachers',
      desc: '',
      args: [],
    );
  }

  /// `View Attendance`
  String get viewAttendance {
    return Intl.message(
      'View Attendance',
      name: 'viewAttendance',
      desc: '',
      args: [],
    );
  }

  /// `School Calendar`
  String get schoolCalendar {
    return Intl.message(
      'School Calendar',
      name: 'schoolCalendar',
      desc: '',
      args: [],
    );
  }

  /// `{feature} coming soon!`
  String comingSoon(Object feature) {
    return Intl.message(
      '$feature coming soon!',
      name: 'comingSoon',
      desc: '',
      args: [feature],
    );
  }

  /// `No comments yet`
  String get noCommentsYet {
    return Intl.message(
      'No comments yet',
      name: 'noCommentsYet',
      desc: '',
      args: [],
    );
  }

  /// `Be the first to comment!`
  String get beFirstToComment {
    return Intl.message(
      'Be the first to comment!',
      name: 'beFirstToComment',
      desc: '',
      args: [],
    );
  }

  /// `Reply`
  String get reply {
    return Intl.message('Reply', name: 'reply', desc: '', args: []);
  }

  /// `Write a comment...`
  String get writeAComment {
    return Intl.message(
      'Write a comment...',
      name: 'writeAComment',
      desc: '',
      args: [],
    );
  }

  /// `Write a reply...`
  String get writeAReply {
    return Intl.message(
      'Write a reply...',
      name: 'writeAReply',
      desc: '',
      args: [],
    );
  }

  /// `Comment added successfully!`
  String get commentAddedSuccessfully {
    return Intl.message(
      'Comment added successfully!',
      name: 'commentAddedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Post deleted successfully!`
  String get postDeletedSuccessfully {
    return Intl.message(
      'Post deleted successfully!',
      name: 'postDeletedSuccessfully',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
