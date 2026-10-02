abstract final class Routes {
  static const landing = '/';
  static const home = '/home';
  static const signin = '/signin';
  static const signup = '/signup';
  static const tasks = '/tasks';
  static const createTask = '/tasks/create';
  static const allTasks = '/tasks/all';
  static const task = '/tasks/:taskId';
  static const editTask = '/tasks/:taskId/edit';
  static const taskPhoto = '/tasks/:taskId/photo';
  static const profile = '/profile';
  static const profileInformation = '/profile/information';
  static const profileNotifications = '/profile/notifications';
  static const profileSettings = '/profile/settings';

  static String taskPath(String taskId) => '/tasks/$taskId';
  static String editTaskPath(String taskId) => '/tasks/$taskId/edit';
  static String taskPhotoPath(String taskId) => '/tasks/$taskId/photo';

  static const publicRoutes = [landing, signin, signup];
}
